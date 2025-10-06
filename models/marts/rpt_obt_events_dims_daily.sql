with
events as (
    select
        *
    from
        {{ ref('rpt_obt_events') }}
),

-- not forcing a granularity
-- group by all columns, which are created dynamically and can change
-- dims include: server date, client date, path_entered, framework_item...
final as (
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
            user_invite_status,
            event_value,
            event_path
        ),
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
