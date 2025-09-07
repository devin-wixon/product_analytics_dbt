with

events as (
    select * exclude (event_path, event_value)
    from
        {{ ref("int_events_enriched") }}
),

final as (
    select *
    from
        events
)

select *
from
    final
