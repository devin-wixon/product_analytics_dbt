with

district_programs as (
    select 
        *
    from {{ ref('stg_taco__district_programs') }}
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