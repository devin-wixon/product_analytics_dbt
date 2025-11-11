with
events as (
    select *
    from
        {{ ref('rpt_obt_events') }}
),

-- not forcing a granularity
-- group by all columns, which are created dynamically and can change
-- dims include: server date, client date, path_entered, framework_item...
final as (
    select
        user_id,
        user_role,
        server_event_date,
        event_path,
        event_category,
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
        true as had_events_per_user_day_context,
        count(event_id) as n_events_per_user_day_context,
        -- using one event_id in the context as a key for traceability
        min(event_id) as example_event_id
    from
        events
    group by all
)

select *
from
    final
where
    user_role != 'student'
    or user_role is null
