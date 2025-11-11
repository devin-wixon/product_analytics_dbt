with

resources as (
    select
        * exclude (
            dbt_scd_id,
            dbt_updated_at
        )
    from {{ ref('stg_craft__resources') }}
    where
        dbt_valid_to is null

),

programs as (
    select
        program_id,
        program_name
    from
        {{ ref('dim_programs_most_recent') }}
),

final as (
    select
        resources.*,
        programs.program_name as resource_program_name
    from
        resources
    left join
        programs
        on
            resources.resource_program_id = programs.program_id
)

select *
from
    final
