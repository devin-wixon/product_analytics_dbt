with
    events as
(
    select 
        *
    from 
        {{ ref('rpt_obt_events') }}
),

-- group by all columns, which are created dynamically and can change
-- exclude the columns below desired dimension granularity
-- which are: event_category, server date, client date, path_entered, path_left, program, resource, framework, framework_item, folder, week number, application name, sidebar section, etc.
-- keeping for now some low granularity: search_string
final as
(select
    count(event_id) as n_events,
    -- using one event_id that occured in the context as a surrogate key for traceability
    min(event_id) as user_day_dims_events_sk,
    * exclude (
        event_id,
        server_timestamp,
        client_timestamp,
        event_name,
        event_value_human_readable
)
from
    events
group by all
)
select
    *
from
    final