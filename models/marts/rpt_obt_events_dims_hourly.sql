
with
-- not incremental; uses most recent values from dims
events as (
    select *
    from
        {{ ref('rpt_obt_events') }}
),

-- not forcing a granularity
-- group by all columns, which are created dynamically and can change
aggregated as (
    select
        user_id,
        user_role,
        client_timestamp_hour,
        server_event_date,
        -- event details
        -- human readable: for resources filters and resource more sidebar
        event_value_human_readable,
        -- path: for pageviews
        event_path,
        event_category,
        event_type,
        is_planner_event,
        search_string,
        -- program level
        program_id,
        program_name,
        -- resource level
        resource_id,
        resource_title,
        resource_program_id,
        resource_program_name,
        -- district level
        district_id,
        district_type,
        district_name,
        district_state,
        resource_type,
        -- date parts
        week_monday_date,
        month_start_date,
        short_weekday_name,
        year_month_sort,
        school_year_label,
        school_year_start_date,
        count(event_id) as n_events_per_user_dim_context,
        -- using one event_id in the context as a key for traceability
        min(event_id) as example_event_id
    from
        events
    group by all
),

final as (
    select *
    from
        aggregated
    where
        user_role != 'student'
        or user_role is null
)

select *
from
    final
