with

resources as (
    select
        * exclude (
            dbt_scd_id,
            dbt_valid_from,
            dbt_valid_to,
            dbt_updated_at,
            dbt_is_deleted
        )
    from {{ ref('stg_craft__resources') }}
    where
        dbt_valid_to is null
),
programs as
(select 
    program_id,
    program_name
from 
    {{ ref('dim_programs_current') }}
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
