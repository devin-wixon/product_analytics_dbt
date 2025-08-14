
with

users as 
(select
    *
from
    {{ ref('dim_users_current') }}
),

events as (
    select
        *
    from
        {{ ref('fct_events') }}
),

user_daily_events as 
(select
    users.user_id,
    users.user_role,
    users.user_grades,
    users.user_other_grades,
    events.event_date,

    -- boolean metrics
    max(is_login_event)::boolean as has_login_event,
    max(is_planner_open_event)::boolean as has_planner_open_event,
    max(is_weekly_planner_event)::boolean as has_weekly_planner_event,
    max(is_app_launch_event)::boolean as has_app_launch_event,

    -- Count metrics
    count(events.event_id) as n_total_events,
    count(distinct resource_id) as n_resources_accessed,
    count(distinct program_id) as n_programs_accessed,
    -- event_value for app launch event is not the application_id, but text
    count(distinct case when is_app_launch_event then event_value end) as n_apps_launched
from
    users
join
    events
on
    users.user_id = events.user_id
group by
    users.user_id,
    users.user_role,
    users.user_grades,
    users.user_other_grades,
    events.event_date
),

final as
(select
    *
from
    user_daily_events
)

select
    *
from
    final