with

district_applications as (
    select 
        *
    from {{ ref('stg_taco__district_applications') }}
    where 
        dbt_valid_from <= current_timestamp()
        and dbt_valid_to >= current_timestamp()
),

final as (
    select 
        *
    from district_applications
)

select
    *
from
    final