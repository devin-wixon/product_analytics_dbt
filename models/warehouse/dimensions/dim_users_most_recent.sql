with

users as (
    select
        * exclude (
            dbt_scd_id,
            dbt_updated_at
        )
    from {{ ref('stg_taco__users') }}
    where
        dbt_valid_to is null
),


final as (
    select *
    from users
)

select *
from final
