with

applications as (
    select *
    from {{ ref('stg_taco__applications') }}
),

final as (
    select *
    from applications
)

select *
from
    final
