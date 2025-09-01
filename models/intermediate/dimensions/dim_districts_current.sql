with

districts as (
    select 
        *  exclude( dbt_scd_id, dbt_valid_from, dbt_valid_to, dbt_updated_at, dbt_is_deleted )       
    from {{ ref('stg_taco__districts') }}
    where 
        dbt_valid_from <= current_timestamp()
        and dbt_valid_to is null
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