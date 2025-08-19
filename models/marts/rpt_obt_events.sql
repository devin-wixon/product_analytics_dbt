
{{ config(
  enabled = False
)}}

-- using exclude rather than explicit columns
-- to ensure new columns are included
with users as (
    select
        * exclude (
          user_sourced_id,
        is_diable_auto_sync,
        is_manually_added,
        )
    from
        {{ ref('dim_users_current') }}
),
districts as (
    select
        * exclude (
          district_address,
          district_city,
          is_manually_added,
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
          district_last_modfied_at_utc,
          roster_file_created_at_utc,
          auto_rostering_checked_at_utc,





        )
    from
        {{ ref('dim_districts_current') }}
),

programs as (
    select
        *
    from
        {{ ref('dim_programs') }}
),

resources as (
    select
        *
    from
        {{ ref('dim_resources_current') }}
),

-- columns may be generated through pivots in int_ layer
events as (
  select
    * exclude(

    )
  from
    {{ ref('fct_events') }}
), 
-- TAG TO DO prune column list after investigate how used (ex: resource description)
joined as (
  select
    events.*,
    users.* exclude (user_id),
    districts.* exclude (district_id),
    programs.* exclude (program_id),
    resources.* exclude (resource_id, resource_description, program_id, focus_area_id)
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
  limit 100000
{%- endif -%}
)

select 
  *
from
  final