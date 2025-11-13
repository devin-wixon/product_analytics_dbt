with 


event_category_agg as (
    select 
        program_id || '-' || event_category as program_event_category_id,
        program_id,
        program_name,
        event_category,
        min(server_event_date) as first_active_date_program_event_category,
        max(server_event_date) as last_active_date_program_event_category
    from
        {{ ref('rpt_obt_events') }}
    where
        program_id is not null
    group by
        program_id,
        program_name,
        event_category
),


final as (
    select *
    from event_category_agg
)

select *
from
    final
order by
    program_event_category_id