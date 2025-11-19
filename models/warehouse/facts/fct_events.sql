{{ config(
    materialized='incremental',
    incremental_strategy='append'
) }}

with

events as (
    select *
    from
        {{ ref("int_events_enriched") }}
    {% if is_incremental() %}
    where server_event_date > (select max(server_event_date) from {{ this }})
    {% endif %}
    {{ dev_limit(1000) }}
),


final as (
    select *
    from
        events
)

select *
from
    final
