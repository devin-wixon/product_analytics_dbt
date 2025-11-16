with

event_categories as (
    select
        event_category,
        min()
    from
        {{ ref('seed_event_log_metadata') }}
),

joined as (
    select
        resources.resource_program_id,
        programs.program_name,
        resources.resource_type,
        resources.resource_program_id
        || '-'
        || resources.resource_type as program_resource_type_id,
        count(resources.resource_id) as n_resources_in_program_resource_type,
    from resources
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
