with

events as (
    select
        *
    from
        {{ ref("int_events_enriched")}}
),

final as (
    select
        *
    from
        events
)

select
    *
from
    final