with
source_table as (
    select *
    from
        {{ source('taco', 'raw_taco__users_grades') }}
),

final as (
    select
        id::int as user_grade_id,
        user_id::int as user_id,
        grade_id::int as grade_id,

        -- timestamps
        created_at::timestamp as created_at_utc,
        updated_at::timestamp as updated_at_utc,
        deleted_at::timestamp as deleted_at_utc
    from source_table
)

select *
from
    final
