with 

users as 
(select
    *  exclude( dbt_scd_id, dbt_valid_from, dbt_valid_to, dbt_updated_at, dbt_is_deleted )    
from
    {{ ref('stg_taco__users') }}
where
    user_role != 'student'
    and dbt_valid_from <= current_timestamp()
    and dbt_valid_to is null
),

-- denormalize disrict, which is 1:1 with users
-- districts as 
-- (select
--     *
-- from
--     {{ ref('dim_districts_current') }}

-- ),

joined as
(select
    users.user_id,
    users.user_role,
    users.district_id,
    -- district attributes
    -- districts.district_id,
    -- districts.district_name,
    -- districts.district_state,
    -- district_type,
    users.user_sourced_id,
    users.is_disable_auto_sync,
    users.is_manually_added,
    users.user_invite_status,
    users.user_grades,
    users.user_other_grades,
    users.email_sent_utc,
    users.last_modified_at_utc as user_last_modified_at_utc

from
    users
-- inner join
--     districts
-- on
--     users.district_id = districts.district_id   
),
final as
(select
    *
from
    joined
)

select
    *
from
    final
