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
    min(event_id) as row_index,
    * exclude (
        event_id, 
        server_timestamp, 
        client_timestamp, 
        event_name)
from
    events
group by all
)
select
    *
from
    final