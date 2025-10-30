with

resources as (
    select
        * exclude (
            dbt_scd_id,
            dbt_updated_at
        ),
        dbt_is_deleted or resource_deleted_at is not null as is_resource_deleted
    from {{ ref('stg_craft__resources') }}
    qualify row_number() over (
        partition by resource_id
        order by dbt_valid_from desc
    ) = 1
        
),
programs as
(select 
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
