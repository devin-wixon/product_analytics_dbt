with

resources as (
    select 
        *
    from {{ ref('stg_craft__resources') }}
    where 
        dbt_valid_from <= current_timestamp()
        and dbt_valid_to >= current_timestamp()
),

final as (
    select 
        *
    from resources
)

select
    *
from
    final