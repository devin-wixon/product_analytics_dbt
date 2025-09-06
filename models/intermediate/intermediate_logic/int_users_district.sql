with 

-- a user may have many records in the staging model because it is a snapshot with date-based change capture
-- a user will only ever have one district_id
-- and this chooses administrator over teacher if there are multiple roles for a user
users_district_role as 
(select
    user_id,
    district_id,
    min(user_role) as user_highest_role
from
    {{ ref('stg_taco__users') }}
where
    user_role != 'student'
group by
    user_id,
    district_id
),

final as
(select
    *
from
    users_district_role
) 

select
    *
from
    final