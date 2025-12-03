{{ config(
    materialized='incremental',
    incremental_strategy='append',
    on_schema_change='ignore'
) }}

with

events as (
    select distinct
        user_id,
        server_event_date,
        -- batch tracking for incremental loads
        to_number(
            {% if is_incremental() %}
                (select max(dbt_row_batch_id) + 1 from {{ this }})
            {% else %}
                0
            {% endif %},
            38, 0
        ) as dbt_row_batch_id
    from
        {{ ref('fct_events') }}
    where
        user_id is not null
        and server_event_date is not null
    {% if is_incremental() %}
            and date(server_timestamp)
                > (select max(server_event_date) from {{ this }})
        {% endif %}
),

users_history as (
    select
        user_id,
        district_id,
        user_invite_status,
        user_role,
        dbt_valid_from,
        dbt_valid_to
    from
        {{ ref('dim_users_history') }}
),

-- User-Event matching with exact SCD logic
user_events_exact as (
    select
        events.user_id,
        events.server_event_date,
        events.dbt_row_batch_id,
        users_history.district_id,
        users_history.user_invite_status,
        users_history.user_role,
        'exact' as match_type
    from events
    inner join users_history on
        events.user_id = users_history.user_id
        and events.server_event_date >= users_history.dbt_valid_from::date
        and (
            users_history.dbt_valid_to is null
            or events.server_event_date < users_history.dbt_valid_to::date
        )
),

-- Fallback logic for events without exact matches
user_events_fallback as (
    select
        events.user_id,
        events.server_event_date,
        events.dbt_row_batch_id,
        users_history.district_id,
        users_history.user_invite_status,
        users_history.user_role,
        'fallback' as match_type
    from events
    left join user_events_exact
        on
            events.user_id = user_events_exact.user_id
            and events.server_event_date = user_events_exact.server_event_date
    inner join users_history
        on
            events.user_id = users_history.user_id
    where
        user_events_exact.user_id is null  -- Only events without exact match
    qualify row_number() over (
        partition by events.user_id, events.server_event_date
        order by
            -- Calculate minimum distance to the valid date range
            case
                when
                    events.server_event_date
                    < users_history.dbt_valid_from::date
                    then
                        datediff(
                            day,
                            events.server_event_date,
                            users_history.dbt_valid_from::date
                        )
                when
                    users_history.dbt_valid_to is not null
                    and events.server_event_date
                    >= users_history.dbt_valid_to::date
                    then
                        datediff(
                            day,
                            users_history.dbt_valid_to::date,
                            events.server_event_date
                        )
                else 0  -- Should not happen, but safeguard
            end asc,
            -- Tiebreaker: prefer most recent record
            users_history.dbt_valid_from desc
    ) = 1
),

-- Combine exact and fallback matches
final as (
    select
        server_event_date,
        user_id,
        district_id,
        user_invite_status,
        user_role,
        match_type,
        dbt_row_batch_id
    from
        user_events_exact

    union all

    select
        server_event_date,
        user_id,
        district_id,
        user_invite_status,
        user_role,
        match_type,
        dbt_row_batch_id
    from
        user_events_fallback
)

select *
from
    final
