{{ config(
    materialized='incremental',
    incremental_strategy='append',
    on_schema_change='append_new_columns'
) }}

with

events as (
    select * exclude (dbt_row_batch_id),
    -- batch tracking for incremental loads
    to_number(
        {% if is_incremental() %}
            (select max(dbt_row_batch_id) + 1 from {{ this }} )
        {% else %}
            0
        {% endif %},
        38, 0
    ) as dbt_row_batch_id
    from {{ ref('fct_events') }}
    {% if is_incremental() %}
    where server_event_date > (select max(server_event_date) from {{ this }})
    {% endif %}
),

user_context as (
    select
        user_id,
        server_event_date,
        district_id,
        user_invite_status,
        user_role,
        match_type
    from {{ ref('int_users_district_role_date') }}
),

events_with_user_context as (
    select
        events.*,
        user_context.district_id,
        user_context.user_invite_status as user_invite_status_event_date,
        user_context.user_role as user_role_event_date,
        user_context.match_type,
    from events
    left join user_context
        on events.user_id = user_context.user_id
        and events.server_event_date = user_context.server_event_date
),

final as (
    select *
    from events_with_user_context
)

select *
from final
