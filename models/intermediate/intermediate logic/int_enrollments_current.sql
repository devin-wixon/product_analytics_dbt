with

enrollments as (
    select 
        user_id,

        -- attributes
        role::string as user_role,
        class_id,
        school_id::int as school_id,
        district_id,
        is_primary,

        -- status,
        -- is_active, -- always true as of 8/12/25
        -- role_id::int as role_id,
        
        start_date,
        end_date,
        last_modified_at_utc

        -- ids not included
            -- enrollment_id,
            -- user_sourced_id,
            -- class_sourced_id,
            -- school_sourced_id,
            -- user_source_id,
            -- sourced_id::string as sourced_id,

     from {{ ref('stg_taco__enrollments') }} 
    where 
      (start_date is null or start_date <= current_date())
      and (end_date is null or end_date > current_date())
      and role != 'student'
),

-- select one record per user x role x class x school, prioritizing most recent modification
user_current_enrollment as (
    select
        *
    from enrollments
    qualify row_number() over (partition by user_id, role, class_id, school_id order by last_modified_at_utc desc) = 1

),

final as 
( select
    user_id,
    role,
    class_id,
    school_id,
    district_id,
    is_primary,
    start_date,
    end_date,
    last_modified_at_utc
from 
    user_current_enrollment
)

select
    *
from
    final
