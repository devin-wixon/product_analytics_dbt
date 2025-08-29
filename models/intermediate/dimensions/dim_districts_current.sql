with

districts as (
    select 
        *
    from {{ ref('stg_taco__districts') }}
    where 
        dbt_valid_from <= current_timestamp()
        and dbt_valid_to >= current_timestamp()
),

final as (
    select 
        *
    from districts
)

select
    *
from
    final