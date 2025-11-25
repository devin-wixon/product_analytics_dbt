with

programs as (
    select
        program_id,
        program_name
    from
        {{ ref('dim_programs_most_recent') }}
),

-- only include current resources
-- deleted, test resourcs may falsely appear to be a native program
resources as (
    select
        resource_id,
        resource_type,
        resource_program_id,
        resource_program_id
        || '-'
        || resource_type as program_resource_type_id,
        count(resource_id) as n_resources_in_program_resource_type
    from
        {{ ref('dim_resources_most_recent') }}
    where
        is_resource_deleted = false
    group by 
        resource_id,
        resource_type,
        resource_program_id,
        program_resource_type_id
),

joined as (
    select
        -- name to distinguish event program vs resource program
        resources.resource_program_id,
        programs.program_name as resource_program_name,
        resources.resource_type,
        resources.n_resources_in_program_resource_type,
        resources.program_resource_type_id,
        resources.n_resources_in_program_resource_type > 1 as has_multiple_resources_in_program_resource_type
    from resources
    left join programs
        on resources.resource_program_id = programs.program_id
    having n_resources_in_program_resource_type = 1
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
