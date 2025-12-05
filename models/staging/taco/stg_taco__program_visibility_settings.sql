with
source_table as (
    select *
    from
        {{ source('taco', 'raw_taco__program_visibility_settings') }}
),

final as (
    select
        id::int as program_visibility_id,
        district_id::int as district_id,
        school_id::int as school_id,
        class_id::int as class_id,
        district_grade_id::int as grade_id,
        program_id:int as program_id,

        -- boolean
        enabled::boolean as is_visibility_enabled,

        -- timestamps
        created_at::timestamp as created_at_utc,
        updated_at::timestamp as updated_at_utc,
        deleted_at::timestamp as deleted_at_utc
    from source_table
)

select *
from
    final
