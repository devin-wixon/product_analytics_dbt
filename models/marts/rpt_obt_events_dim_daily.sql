with
    events as
(
    select 
        *
    from 
        {{ ref('rpt_obt_events') }}
),

-- group by all columns, which are created dynamically and can change
-- except the dimensions above the event_id granularity
final as
(select
    count(event_id) as n_events,
    * exclude (
        event_id, 
        server_timestamp, 
        notes, event_trigger, 
        handled_as_exception_in_code, 
        example_values, 
        event_capture_end_date, 
        event_capture_start_date, 
        client_timestamp, event_name)
from
    events
group by all
)
select
    *
from
    final