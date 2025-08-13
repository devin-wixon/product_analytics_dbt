with

districts as (
    select 
        *
    from {{ ref('stg_taco__districts') }}
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