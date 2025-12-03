{{ config(
    materialized='incremental',
    incremental_strategy='append',
    on_schema_change='append_new_columns'
) }}

with

events as (
    select
        * exclude (dbt_row_batch_id),
        -- batch tracking for incremental loads
        to_number(
            {% if is_incremental() %}
                (select max(dbt_row_batch_id) + 1 from {{ this }} )
            {% else %}
                0
            {% endif %},
            38, 0
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
