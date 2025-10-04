with

districts as (
    select
        *,
        {{ is_distributed_demo_district('district_id') }} as is_distributed_demo_district
    from {{ ref('stg_taco__districts') }}
    where
        dbt_valid_to is null
),

district_settings as (
    select
        * exclude (
            dbt_valid_from,
            dbt_valid_to,
            dbt_is_deleted)
    from {{ ref('int_district_settings_history') }}
    where
        dbt_valid_to is null
),

joined as (
    select
        districts.*,
        district_settings.* exclude (dbt_scd_id, district_id, district_settings)
    from districts
    left join district_settings
        on districts.dbt_scd_id = district_settings.dbt_scd_id
),

final as (
    select *
    from joined
)

select *
from final
