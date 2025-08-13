with

resources as (
    select 
        *
    from {{ ref('stg_craft__resources') }}
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