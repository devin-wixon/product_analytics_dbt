{{ config(
    materialized='incremental',
    incremental_strategy='append'
) }}

with events as (
    select
        * exclude (dbt_row_batch_id),
        -- batch tracking for incremental loads
        to_number(
            {% if is_incremental() %}
                (select max(dbt_row_batch_id) + 1 from {{ this }} )
            {% else %}
                0
            {% endif %}, 
            38, 0
        ) as dbt_row_batch_id
    from
        {{ ref('fct_events') }}
    {% if is_incremental() %}
        where
            date(server_timestamp)
                > (select max(server_event_date) from {{ this }})
    {% endif %}
),

user_district_role_date as (
    select
        server_event_date,
        user_id,
        district_id,
        user_role,
        user_invite_status,
        match_type
    from
        {{ ref('int_users_district_role_date') }}
),

event_user_joined as (
    select
        events.*,
        user_district_role_date.district_id,
        user_district_role_date.user_role,
        user_district_role_date.user_invite_status,
        user_district_role_date.match_type
    from events
    left join user_district_role_date on
        events.user_id = user_district_role_date.user_id
        and events.server_event_date = user_district_role_date.server_event_date
),

user_daily_activity as (
    select
        {{ dbt_utils.generate_surrogate_key([
            'user_id',
            'server_event_date',
            "coalesce(user_role, 'none')",
            'coalesce(district_id, -1)',
            'coalesce(program_id, -1)',
            'coalesce(resource_id, -1)',
            "coalesce(application_name, 'none')",
            "coalesce(event_category, 'none')"
        ]) }} as user_daily_context_sk,

        count(event_id) as n_events_per_user_day_context,
        true as had_events_per_user_day_context,
        user_id,
        server_event_date,
        district_id,
        program_id,
        resource_id,
        application_name,
        event_category,
        user_role,
        user_invite_status,
        match_type,
        dbt_row_batch_id
    from
        event_user_joined
    group by all
),

final as (
    select *
    from
        user_daily_activity
)

select *
from
    final
