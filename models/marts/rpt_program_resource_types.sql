with

programs as (
    select
        program_id,
        program_name
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

joined as (
    select
        -- name to distinguish event program vs resource program
        resources.resource_program_id,
        programs.program_name as resource_program_name,
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
