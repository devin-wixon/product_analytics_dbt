with

categories as (
    select
        event_category,
        min(event_capture_start_date) as min_event_name_start_date_category,
        max(event_capture_start_date) as max_event_name_start_date_category
    from
        {{ ref('seed_event_log_metadata') }}
    group by
        event_category
),

events as 
(select
    event_category,
    program_id,
    min(server_event_date) as first_active_date_program_category,
    max(server_event_date) as last_active_date_program_category
from
    {{ ref('fct_events') }}
group by
    event_category,
    program_id

),

joined as (
    select
        events.program_id
        || '-'
        || categories.event_category as program_event_category_id,
        events.program_id,
        categories.event_category,
        categories.min_event_name_start_date_category,
        categories.max_event_name_start_date_category,
        events.first_active_date_program_category,
        events.last_active_date_program_category
    from categories
    left join events
        on categories.event_category = events.event_category
    group by
        program_event_category_id,
        categories.event_category,
        events.program_id
),

final as (
    select *
    from joined
)

select *
from
    final
order by
    program_resource_type_id
