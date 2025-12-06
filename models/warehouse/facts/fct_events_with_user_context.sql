{{ config(
    materialized='incremental',
    incremental_strategy='append',
    on_schema_change='append_new_columns'
) }}

with

events as (
    select *
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

districts as (
    select
        district_id,
        district_name,
        district_type,
        district_state,
        district_state_international,
        district_city,
        district_tags,
        is_distributed_demo_district
    from {{ ref('dim_districts_most_recent') }}
),

events_with_user_context as (
    select
        events.*,
        user_context.district_id,
        user_context.user_invite_status,
        user_context.user_role,
        user_context.match_type,
        districts.district_name,
        districts.district_type,
        districts.district_state,
        districts.district_state_international,
        districts.district_city,
        districts.district_tags,
        districts.is_distributed_demo_district
    from events
    left join user_context
        on events.user_id = user_context.user_id
        and events.server_event_date = user_context.server_event_date
    left join districts
        on user_context.district_id = districts.district_id
),

final as (
    select *
    from events_with_user_context
)

select *
from final
