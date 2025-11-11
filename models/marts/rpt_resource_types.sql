with 

resources as (
    select
        resource_id,
        resource_type
    from
        {{ ref('dim_resources_most_recent') }}
),

event_resource_ids as (
    select 
        resource_id,
        min(server_event_date) as resource_id_first_active_date,
        max(server_event_date) as resource_id_last_active_date
    from
        {{ ref('fct_events') }}
    group by
        resource_id
),
joined as (
    select
        resources.resource_type,
        min(event_resource_agg.resource_id_first_active_date) as resource_type_first_active_date,
        max(event_resource_agg.resource_id_last_active_date) as resource_type_last_active_date
    from resources
    left join event_resource_ids as event_resource_agg
    on resources.resource_id = event_resource_agg.resource_id
    group by
        resource_type
),

final as (
    select *
    from joined
)

select *
from
    final