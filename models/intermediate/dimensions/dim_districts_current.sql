with

districts as (
    select 
        *
    from {{ ref('stg_taco__districts') }}
),

district_settings as (
    select 
        *
    from {{ ref('int_district_settings') }}
),

joined as (
    select 
        *
    from districts
    left join district_settings on districts.district_id = district_settings.district_id
)

final as (
    select 
        *
    from joined
)

select
    *
from
    final