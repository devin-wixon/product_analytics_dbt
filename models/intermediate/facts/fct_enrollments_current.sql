with

enrollments as (
    select
        * exclude (
            dbt_scd_id,
            -- dbt_valid_from,
            -- dbt_valid_to,
            dbt_updated_at,
            dbt_is_deleted
        )
    from
        {{ ref('fct_enrollments_history') }}
    where
        -- start and end dates are optional and often null
        -- but will be used where available
        (
            enrollment_start_date is null
            or enrollment_start_date > current_date
        )
        and (
            enrollment_start_date is null
            or enrollment_start_date > current_date
        )
        -- filter to current records from snapshot
        and dbt_valid_from <= current_timestamp()
        and dbt_valid_to is null
),

-- select one record per user x role x class x school, prioritizing most recent modification
user_current_enrollment as (
    select *
    from enrollments
    qualify
        row_number()
            over (
                partition by user_id, user_role, class_id, school_id
                order by enrollment_updated_at_utc desc
            )
        = 1

),

final as (
    select
        user_id,
        user_role,
        class_id,
        school_id,
        district_id,
        enrollment_start_date,
        enrollment_end_date,
        dbt_valid_from,
        dbt_valid_to
    from
        user_current_enrollment
)

select *
from
    final
