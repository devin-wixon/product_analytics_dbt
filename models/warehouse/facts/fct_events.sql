with

events as (
    select *
    from
        {{ ref("int_events_enriched") }}
    {{ dev_limit(1000) }}
),


final as (
    select
        events.*
    from
        events
    )


select *
from
    final
