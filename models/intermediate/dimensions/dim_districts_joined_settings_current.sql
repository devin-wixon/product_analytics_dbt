with

districts as (
    select 
        *
    from {{ ref('dim_districts_current') }}
),

district_settings as (
    select 
        *
    from {{ ref('int_district_settings_current') }}
),

joined as (
    select 
        districts.*,
        district_settings.* exclude (district_id)
    from districts
    left join 
        district_settings 
    on 
        districts.district_id = district_settings.district_id
),

final as (
    select 
        *
    from joined
)

select
    *
from
    final