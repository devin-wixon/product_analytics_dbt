with

users as (
    select
        * exclude (
            dbt_scd_id,
            dbt_updated_at
        )
    from {{ ref('stg_taco__users') }}
    qualify row_number() over (
        partition by user_id
        order by dbt_valid_from desc
    ) = 1

),


final as (
    select *
    from users
)

select *
from final
