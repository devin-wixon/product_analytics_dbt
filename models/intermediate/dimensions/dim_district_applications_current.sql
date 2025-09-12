with

district_applications as (
    select
        * exclude (
            dbt_scd_id,
            dbt_valid_from,
            dbt_valid_to,
            dbt_updated_at,
            dbt_is_deleted
        )
    from {{ ref('stg_taco__district_applications') }}
    where
        dbt_valid_to is null
),

final as (
    select *
    from district_applications
)

select *
from
    final
