with

programs as (
    select 
        *
    from {{ ref('stg_craft__programs') }}
),

final as (
    select 
        *
    from programs
)

select
    *
from
    final