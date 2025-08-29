with

district_programs as (
    select 
        *
    from {{ ref('stg_taco__district_programs') }}
    where 
        dbt_valid_from <= current_timestamp()
        and dbt_valid_to >= current_timestamp()
),

final as (
    select 
        *
    from district_programs
)

select
    *
from
    final