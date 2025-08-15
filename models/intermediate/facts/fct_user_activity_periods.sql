with user_daily_activity as (
    select
        user_id,
        date(server_timestamp) as activity_date,
        
        -- Program metrics
        count(distinct program_id) as programs_accessed,
        count(distinct case when is_planner_open_event then program_id end) as programs_with_planner,
        
        -- Resource metrics  
        count(distinct resource_id) as resources_accessed,
        count(distinct case when resource_type = 'video' then resource_id end) as videos_accessed,
        count(distinct case when resource_type = 'document' then resource_id end) as documents_accessed,
        
        -- Event metrics
        count(*) as total_events,
        sum(is_login_event::int) as login_events,
        sum(is_planner_open_event::int) as planner_events,
        sum(is_weekly_planner_event::int) as weekly_planner_events,
        sum(is_app_launch_event::int) as app_launch_events,
        
        -- Session metrics
        count(distinct session_uuid) as sessions,
        datediff('minute', min(server_timestamp), max(server_timestamp)) as active_minutes
        
    from {{ ref('fct_events') }}
    where user_id is not null
    group by user_id, date(server_timestamp)

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