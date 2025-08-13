with

enrollments as (
    select 
        *
    from 
        {{ ref('stg_taco__enrollments') }} 
    where 
        user_role != 'student'
),

-- select one record per user x role x class x school, prioritizing most recent modification
user_current_enrollment as (
    select
        *
    from enrollments
    qualify row_number() over (partition by user_id, user_role, class_id, school_id order by last_modified_at_utc desc) = 1

),

final as 
( select
    user_id,
    user_role,
    class_id,
    school_id,
    district_id,
    is_primary,
    last_modified_at_utc
from 
    user_current_enrollment
)

select
    *
from
    final
