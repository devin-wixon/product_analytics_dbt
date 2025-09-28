
-- using exclude rather than explicit columns
-- to ensure new columns are included
with 

events as (
  select
  -- use * and exclude, not explicit select; columns may be generated through pivots in int_ layer
    *
  from
    {{ ref('fct_events') }}
  {%- if target.name == 'Development' %}
    limit 1000
  {%- endif -%}
), 

users_history as (
    select
        * exclude (
            user_sourced_id,
            is_disable_auto_sync,
            is_manually_added
        )
    from
        {{ ref('dim_users_history') }}
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
        {{ ref('dim_programs_current') }}
),

resources as (
    select
      resource_id,
      resource_program_id,
      resource_author_id,
      resource_code,
      resource_title,
      resource_order_number,
      is_resource_legacy,
      is_resource_downloadable,
      resource_provider_id,
      is_resource_public,
      resource_publication_status,
      resource_publication_origin_id,
      resource_focus_area,
      -- resource_focus_area_id, -- add dimension tables later for focus areas
      -- resource_sub_focus_area_id,
      resource_estimated_time,
      resource_physical_reference,
      resource_type
    from
        {{ ref('dim_resources_current') }}
),


datespine as (
  select
    date_day,
    week_monday_date,
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
    school_year_label,
    school_year_end_date
from
    {{ ref('dim_day_datespine') }}
),

-- User-Event matching with fallback logic for data cleanliness issues
user_events_exact as (
  select 
    events.event_id,
    events.user_id,
    users_history.district_id,
    users_history.user_invite_status,
    users_history.user_role
    -- users_history.user_grades,
    -- users_history.user_other_grades,
    -- users_history.user_email_sent_utc,
    -- users_history.user_updated_at_utc,
    -- users_history.user_created_at_utc,
  from events
  inner join users_history on events.user_id = users_history.user_id
    and users_history.dbt_valid_from <= events.client_timestamp
    and (users_history.dbt_valid_to is null or users_history.dbt_valid_to > events.client_timestamp)
),

user_events_fallback as (
  select 
    events.event_id,
    events.user_id,
    users_history.district_id,
    users_history.user_invite_status,
    users_history.user_role
  from events
  left join user_events_exact on events.event_id = user_events_exact.event_id
  inner join users_history on events.user_id = users_history.user_id
  where 
    user_events_exact.user_id is null  -- events without exact user match
        -- closest in time to event date within user's valid date range
  qualify row_number() over (
      partition by events.event_id 
      order by abs(
                datediff(
                  day, events.client_event_date::date, 
                           coalesce(users_history.dbt_valid_to, '9999-12-31')::date))
    ) = 1
),

user_events_combined as (
  -- Exact SCD matches first (preferred)
  select * exclude (user_id) from user_events_exact
  where user_id is not null
  
  union all
  
  -- Closest temporal matches for orphaned events
  select * exclude (user_id) from user_events_fallback
),

joined as (
  select
    events.*,
    user_events_combined.* exclude (event_id),
    districts.* exclude (district_id),
    programs.* exclude (program_id),
    -- add focus_area table later as needed
    resources.* exclude (resource_id),
    datespine.* exclude (date_day)
from
  events 
  left join user_events_combined on events.event_id = user_events_combined.event_id
  left join districts on user_events_combined.district_id = districts.district_id
  left join programs on events.program_id = programs.program_id
  left join resources on events.resource_id = resources.resource_id
  left join datespine on events.client_event_date = datespine.date_day
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
where
  user_role != 'student' 
  or user_role is null
