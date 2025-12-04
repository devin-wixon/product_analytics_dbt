with

districts as (
    select
        * exclude (is_district_enabled),
        {{ is_distributed_demo_district('district_id') }} as is_distributed_demo_district
    from {{ ref('int_districts_history_parse_settings') }}
    where
        dbt_valid_to is null
),

final as (
    select *
    from districts
)

select *
from final
