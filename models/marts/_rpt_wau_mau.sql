with

datespine as (
    select
        date_day,
        week_monday_date,
        month_start_date,
        school_year_start_date
    from {{ ref('dim_day_datespine') }}
    where
        -- Limit to today and earlier to avoid future dates
        date_day <= CONVERT_TIMEZONE('UTC', CURRENT_TIMESTAMP())::DATE + 1
),

events as (
    select
        server_event_date,
        user_id,
        district_id,
        district_name,
        district_type,
        program_id,
        program_name,
        user_role,
        resource_id,
        resource_type,
        application_name,
        event_category,
        min(example_event_id) as example_event_id,
        max(had_events_per_user_day_context)
            as had_events_per_user_day_context,
        sum(n_events_per_user_day_context)
            as n_events_per_user_day_context
    from {{ ref('rpt_obt_events_dims_daily') }}
    group by all
),

user_first_event as (
    select
        user_id,
        min(server_event_date) as user_first_event_date
    from events
    group by user_id
),

-- for every user that had an event and every day x every dimension, get whether they had events on that day or the 6 prior days
-- and whether they were eligible to be counted as wau/mau on that day (ie had their first event at least 7/28 days prior)
join_datespine_events as (
    select
        datespine.date_day,
        datespine.week_monday_date,
        datespine.month_start_date,
        datespine.school_year_start_date,
        users.user_id,
        users.user_first_event_date,
        events.district_id,
        events.district_name,
        events.district_type,
        events.program_id,
        events.program_name,
        events.user_role,
        events.resource_id,
        events.resource_type,
        events.application_name,
        events.event_category,
        coalesce(events.n_events_per_user_day_context, 0) as n_events_per_user_day_context,
        coalesce(events.had_events_per_user_day_context, false) as had_events_per_user_day_context
    from user_first_event as users
    cross join datespine
    left join events
        on events.user_id = users.user_id
       and events.server_event_date = datespine.date_day
),

final as (
    select
        *,
        -- not eligible for wau/mau calculation if didn't have 28 days to potentially be active
        case
            when date_day >= dateadd('day', 28, user_first_event_date)
            then True
            else False
        end as is_user_first_date_over_28_days,

        -- did the user have events that day or the prior 6 days?
        max(had_events_per_user_day_context) over (
            partition by user_id
            order by date_day
            rows between 6 preceding and current row
        ) as is_user_active_last_7_days,
                -- did the user have events that day or the prior 6 days?
        max(had_events_per_user_day_context) over (
            partition by user_id
            order by date_day
            rows between 28 preceding and current row
        ) as is_user_active_last_28_days
        
    from join_datespine_events
)

select
    *
from final