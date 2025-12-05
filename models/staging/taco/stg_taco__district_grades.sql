with
source_table as (
    select *
    from
        {{ source('taco', 'raw_taco__district_grades') }}
),

final as (
    select
        id::int as district_grade_id,
        district_id::int as district_id,
        grade_id::int as grade_id,

        -- boolean
        enabled::boolean as is_district_grade_enabled,

        -- timestamps
        created_at::timestamp as created_at_utc,
        updated_at::timestamp as updated_at_utc
    from source_table
)

select *
from
    final
