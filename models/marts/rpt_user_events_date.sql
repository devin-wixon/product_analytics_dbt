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

user_daily_activity as (
    select
        users.user_id,
        users.user_role,
        users.user_grades,
        users.user_other_grades,
        events.server_event_date,
        events.client_event_date,
        
        -- Program metrics
        count(distinct events.program_id) as programs_accessed,
        count(distinct case when events.is_planner_open_event then events.program_id end) as programs_with_planner,
        count(distinct case when is_app_launch_event then event_value end) as n_apps_launched

        -- Resource metrics  
        count(distinct events.resource_id) as resources_accessed,
        {% for resource_type in dbt_utils.get_column_values(ref('dim_resources_current'), 'resource_type') %}
            count(distinct case when events.resource_type = '{{ resource_type }}' then events.resource_id end) as n_{{ resource_type }}_accessed,
        {% endfor %}

        
        -- Event metrics
        count(*) as n_total_events,
        sum(events.is_login_event::int) as n_login_events,
        sum(events.is_planner_open_event::int) as n_planner_events,
        sum(events.is_weekly_planner_event::int) as n_weekly_planner_events,
        sum(events.is_app_launch_event::int) as n_app_launch_events,

        -- boolean metrics
            max(is_login_event)::boolean as has_login_event,
            max(is_planner_open_event)::boolean as has_planner_open_event,
            max(is_weekly_planner_event)::boolean as has_weekly_planner_event,
            max(is_app_launch_event)::boolean as has_app_launch_event,


        -- Session metrics: later
        
    from {{ ref('fct_events') }}
    where user_id is not null
    group by 1,2,3,4,5,6

{% if target.name == 'dev' %}
    -- Limit number of rows in development environment
    limit 100000
{% endif %}
),

final as (
    select
        *
    from user_daily_activity
)

select
    *
from final