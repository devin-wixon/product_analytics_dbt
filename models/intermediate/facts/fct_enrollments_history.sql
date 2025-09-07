with

enrollments as (
    select *

    from
        {{ ref('stg_taco__enrollments') }}
    where
        user_role != 'student'
),


final as (
    select
        -- identifiers
        enrollment_id,
        user_id,

        -- foreign keys
        user_role,
        user_role_id,
        class_id,
        school_id,
        district_id,

        -- timestamps
        enrollment_start_date,
        enrollment_end_date,
        last_modified_at_utc,

        -- snapshot columns
        dbt_scd_id,
        dbt_valid_from,
        dbt_valid_to,
        dbt_updated_at,
        dbt_is_deleted

    from
        enrollments
)

select *
from
    final
