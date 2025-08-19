
-- using exclude rather than explicit columns
-- to ensure new columns are included
with users as (
    select
        * exclude (
            user_sourced_id,
            is_disable_auto_sync,
            is_manually_added
        )
    from
        {{ ref('dim_users_current') }}
),
districts as (
    select
        * exclude (
          district_address,
          district_city,
          district_state_international,
          is_district_enabled,
          district_website_slug,
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
        {{ ref('dim_programs') }}
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

-- columns may be generated through pivots in int_ layer
events as (
  select
    * exclude(
        server_timestamp,
        event_value,
        server_event_date,
        event_value_joins_to,
        event_value_not_id
    )
  from
    {{ ref('fct_events') }}
), 
joined as (
  select
    events.*,
    users.* exclude (user_id),
    districts.* exclude (district_id),
    programs.* exclude (program_id),
    -- add focus_area table later as needed
    resources.* exclude (resource_id, resource_focus_area_id)
from
  events 
  left join users on events.user_id = users.user_id
  left join districts on users.district_id = districts.district_id
  left join programs on events.program_id = programs.program_id
  left join resources on events.resource_id = resources.resource_id
),

final as
(select
  *
from
  joined
{%- if target.name == 'Development' %}
  -- Limit number of rows in development environment
  limit 100
{%- endif -%}
)

select 
  *
from
  final