with

district_applications as (
    select 
        *
    from {{ ref('stg_taco__district_applications') }}
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