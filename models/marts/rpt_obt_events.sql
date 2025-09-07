
-- using exclude rather than explicit columns
-- to ensure new columns are included
with 

events as (
  select
  -- use * and exclude, not explicit select; columns may be generated through pivots in int_ layer
    * 
    --   exclude(
    --     server_timestamp,
    --     server_event_date,
    -- )
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
        * exclude (
          district_address,
          district_city,
          district_state_international,
          is_district_enabled,
          district_settings,
          district_general_settings,
          is_district_auto_sync,
          district_sourced_id,
          district_identifier,
          -- district_sales_force_id,
          -- district_mas_id,
          district_sage_id,
          district_last_sync_utc,
          district_last_modified_at_utc,
          roster_file_created_at_utc,
          auto_rostering_checked_at_utc
        )
    from
        {{ ref('dim_districts_current') }}
),

programs as (
    select
        * exclude(
            program_custom_banner,
            program_clone_status,
            program_deleted_date
        )
    from
        {{ ref('dim_programs_current') }}
),

resources as (
    select
        * exclude(
            -- resource_code,
            resource_description,
            resource_file_url,
            resource_section_title,
            resource_link,
            resource_order_number,
            resource_thumbnail_mobile_url,
            resource_thumbnail_web_url,
            resource_uuid,
            resource_physical_page_number,
            resource_fts_title,
            -- TAG TO DO determine how populated;
            -- focus_area is null when focus_area_id is not
            resource_focus_area
        )
    from
        {{ ref('dim_resources_current') }}
),


datespine as (
  select
    date_day,
    day_of_week_number,
    day_of_month_number,
    day_of_year_number,
    week_of_year_number,
    month_of_year_number,
    quarter_of_year_number,
    short_weekday_name,
    short_month_name,
    year_month_sort
from
    {{ ref('dim_day_datespine') }}
),

-- User-Event matching with fallback logic for data cleanliness issues
user_events_exact as (
  select 
    events.event_id,
    events.user_id,
    users_history.* exclude (user_id)
  from events
  inner join users_history on events.user_id = users_history.user_id
    and users_history.dbt_valid_from <= events.client_timestamp
    and (users_history.dbt_valid_to is null or users_history.dbt_valid_to > events.client_timestamp)
),

user_events_fallback as (
  select 
    events.event_id,
    events.user_id,
    users_history.* exclude (user_id)
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
    resources.* exclude (resource_id, resource_focus_area_id),
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
