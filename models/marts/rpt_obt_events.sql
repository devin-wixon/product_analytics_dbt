
with users as (
    select
        *
    from
        {{ ref('dim_users_current') }}
),
districts as (
    select
        *
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

events as (
  select
    *
  from
    {{ ref('int_events_enriched') }}
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