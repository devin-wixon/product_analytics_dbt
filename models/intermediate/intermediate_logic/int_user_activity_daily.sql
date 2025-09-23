with events as (
    select
        user_id,
        client_event_date,
        district_id,
        is_planner_launch_event,
        event_id
    from {{ ref('fct_events') }}
),

user_activity_daily as (
    select
        user_id,
        client_event_date,
        -- user_id will have one unique district_id, so group by doesn't affect metric granularity
        district_id,
        count(event_id) as n_events_per_user_date,
        max(case when is_planner_launch_event = true then 1 else 0 end) as had_planner_launch_event_per_user_date,
        1 as is_active_day_per_user
    from events
    group by
        user_id,
        client_event_date,
        district_id
),

final as (
    select
        user_id,
        client_event_date,
        district_id,
        n_events_per_user_date,
        had_planner_launch_event_per_user_date,
        is_active_day_per_user
    from user_activity_daily
)

select *
from final