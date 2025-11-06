-- using exclude rather than explicit columns
-- to ensure new columns are included
with

events as (
    select *
    -- use * with exclude, not explicit select; cols may be dynamic
    from
        {{ ref('fct_events') }}
),

users_by_date as (
    select
        server_event_date,
        user_id,
        district_id,
        user_invite_status,
        user_role,
        match_type
    from
        {{ ref('int_users_district_role_date') }}
),

districts as (
    select
        district_id,
        district_name,
        district_type,
        district_state,
        district_website_slug,
        is_distributed_demo_district
    from
        {{ ref('dim_districts_current') }}
),

programs as (
    select
        program_id,
        program_name,
        program_age_group,
        is_program_supplemental,
        program_type,
        is_program_district_auto_add,
        program_language,
        program_license_type,
        program_release_year,
        program_phase,
        program_market_specific,
        is_program_demo

    from
        {{ ref('dim_programs_most_recent') }}
),

resources as (
    select
        resource_id,
        resource_program_id,
        -- occasional errors lead to a different program for the resource
        resource_program_name,
        resource_theme,
        resource_week,
        -- resource_author_id,
        -- resource_code,
        resource_title,
        -- resource_order_number,
        -- is_resource_legacy,
        -- is_resource_downloadable,
        -- resource_provider_id,
        -- is_resource_public,
        -- resource_publication_status,
        -- resource_publication_origin_id,
        resource_focus_area,
        -- resource_focus_area_id, -- add dimension tables later for focus areas
        -- resource_sub_focus_area_id,
        -- resource_estimated_time,
        -- resource_physical_reference,
        resource_type
    from
        {{ ref('dim_resources_most_recent') }}
),


datespine as (
    select
        date_day,
        week_monday_date,
        month_start_date,
        day_of_week_number,
        day_of_month_number,
        day_of_year_number,
        week_of_year_number,
        month_of_year_number,
        quarter_of_year_number,
        short_weekday_name,
        short_month_name,
        year_month_sort,
        year_quarter_sort,
        -- wau_lookback_start_date,
        -- mau_lookback_start_date,
        school_year_label,
        school_year_start_date
    from
        {{ ref('dim_day_datespine') }}
),

joined as (
    select
        events.*,
        users_by_date.* exclude (server_event_date, user_id),
        districts.* exclude (district_id),
        programs.* exclude (program_id),
        -- add focus_area table later as needed
        resources.* exclude (resource_id),
        datespine.* exclude (date_day)
    from
        events
    left join
        users_by_date
        on events.user_id = users_by_date.user_id
        and events.server_event_date = users_by_date.server_event_date
    left join
        districts
        on users_by_date.district_id = districts.district_id
    left join programs on events.program_id = programs.program_id
    left join resources on events.resource_id = resources.resource_id
    left join datespine on events.server_event_date = datespine.date_day
),

final as (
    select *
    from
        joined
)

select *
from
    final