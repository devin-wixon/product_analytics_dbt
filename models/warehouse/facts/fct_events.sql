{{ config(
    materialized='incremental',
    incremental_strategy='append'
) }}

with

events as (
    select
        * exclude (dbt_row_batch_id),
        -- each incremental model tracks its own batch_id for independent pipeline monitoring
        to_number(
            {% if is_incremental() %}
                (select max(dbt_row_batch_id) + 1 from {{ this }} )
            {% else %}
            0
            {% endif %}
            , 38, 0
        ) as dbt_row_batch_id
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
