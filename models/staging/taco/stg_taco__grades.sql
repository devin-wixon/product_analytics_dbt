with
source_table as (
    select *
    from
        {{ source('taco', 'raw_taco__grades') }}
),

final as (
    select
        id::int as grade_id,
        name::string as grade_name,
        description::string as grade_description,

        -- boolean
        enabled::boolean as is_grade_enabled,
    from source_table
)

select *
from
    final
