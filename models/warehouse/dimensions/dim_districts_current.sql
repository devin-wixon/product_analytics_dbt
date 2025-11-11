with

districts as (
    select *
    from {{ ref('dim_districts_most_recent') }}
    where
        dbt_valid_to is null
),

final as (
    select *
    from districts
)

select *
from final
