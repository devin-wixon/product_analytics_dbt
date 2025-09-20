with

events as (
    select * exclude (event_path, event_value)
    from
        {{ ref("int_events_enriched") }}
),

-- a user can never switch districts, so this is a 1:1 mapping that is not date-specific
-- district_id needs to be in fct_events for semantic modeling
    users_district as (
        select
            user_id,
            district_id
        from
            {{ ref("int_users_district") }}
    ),

final as (
    select
        events.*,
        users_district.district_id
    from
        events
    left join users_district
        on events.user_id = users_district.user_id
    )


select *
from
    final
