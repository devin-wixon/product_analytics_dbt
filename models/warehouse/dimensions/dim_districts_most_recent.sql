with

districts as (
    select
        *,
        {{ is_distributed_demo_district('district_id') }} as is_distributed_demo_district
    from {{ ref('int_districts_history_parse_settings') }}
    qualify row_number() over (
        partition by district_id
        order by dbt_valid_from desc
    ) = 1
),

final as (
    select *
    from districts
)

select *
from final
