with 

programs as (
    select
        program_id,
        program_name,
    from
        {{ ref('dim_programs_most_recent') }}
),
resources as (
    select
        resource_id,
        resource_type,
        resource_program_id
    from
        {{ ref('dim_resources_most_recent') }}
),

-- get start and end dates for each resource id and program combination
-- a resource-id is program-specific
event_resource_id_agg as (
    select 
        resource_id,
        min(server_event_date) as first_event_date_resource_id,
        max(server_event_date) as last_event_date_resource_id
    from
        {{ ref('fct_events') }}
    group by
        resource_id
),
joined as (
    select
        resources.resource_program_id || '-' || resources.resource_type as program_resource_type_id,
        resources.resource_program_id as resource_program_id,
        programs.program_name as program_name,
        resources.resource_type,
        count(resources.resource_id) as n_resources_in_program_resource_type,
        min(event_resource_id_agg.first_event_date_resource_id) as first_event_date_program_resource_type,
        max(event_resource_id_agg.last_event_date_resource_id) as last_event_date_program_resource_type
    from resources
    left join event_resource_id_agg 
        on resources.resource_id = event_resource_id_agg.resource_id
    left join programs
        on resources.resource_program_id = programs.program_id
    group by
        program_resource_type_id, 
        resources.resource_type, 
        resources.resource_program_id, 
        programs.program_name
),

final as (
    select *
    from joined
)

select *
from
    final
order by
    program_resource_type_id