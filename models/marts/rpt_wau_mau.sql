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

join_datespine_events as (
    -- Cross join datespine with all users to ensure complete coverage
    select
        datespine.date_day,
        datespine.week_monday_date,
        datespine.month_start_date,
        datespine.school_year_start_date,
        events.* exclude(
            had_events_per_user_day_context,
            n_events_per_user_day_context
        ),
        user_first_event.user_first_event_date,
        coalesce(had_events_per_user_day_context, false)
            as had_events_per_user_day_context,
        coalesce(n_events_per_user_day_context, 0)
            as n_events_per_user_day_context
    from datespine
    left join events
        on datespine.date_day = events.server_event_date
    left join user_first_event
        on events.user_id = user_first_event.user_id
),

final as (
    select
        *,
        -- not eligible for wau/mau calculation if didn't have 28 days to potentially be active
        case
            when date_day >= dateadd('day', 28, user_first_event_date)
            then True
            else False
        end as is_user_first_date_over_28_days
    from join_datespine_events
)

select
    *
from final