with
    events as
(
    select 
        * exclude (
        event_id,
        server_timestamp,
        client_timestamp,
        client_event_date,
        event_name,
        event_value_human_readable,
        error_data_object,
        device_orientation,
        screen_resolution,
        -- keeping for now some low granularity: 
        -- search_string,
        visibility_status,
        user_invite_status
    )
    from 
        {{ ref('rpt_obt_events') }}
),

-- not forcing a granularity
-- group by all columns, which are created dynamically and can change
-- dims include: event_category, server date, client date, path_entered, path_left, program, resource, framework, framework_item, folder...
final as
(select
    *,
    count(event_id) as n_events_per_user_day_context,
    True as had_events_per_user_day_context,
    -- using one event_id that occured in the context as a surrogate key for traceability
    min(event_id) as example_event_id
from
    events
group by all
)
select
    *
from
    final
where
    user_role != 'student'
    or user_role is null