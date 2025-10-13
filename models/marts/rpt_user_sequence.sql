
{{
    config(
        materialized='table'
    )
}}

with

events as (
    select
        event_id,
        user_id,
        server_timestamp,
        server_event_date
    from
        {{ ref('fct_events') }}
),

event_sequence as (
    select
        event_id,
        user_id,
        server_timestamp,
        server_event_date,
        dense_rank() over (
            partition by user_id
            order by server_timestamp
        ) as user_event_index,
        dense_rank() over (
            partition by user_id
            order by server_event_date
        ) as user_day_index
    from
        events
),

final as (
    select
        user_id,
        server_timestamp,
        server_event_date,
        event_id,
        user_event_index,
        user_day_index
    from
        event_sequence
)

select *
from
    final