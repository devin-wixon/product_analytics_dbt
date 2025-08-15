 -- One denormalized table with everything
-- benefits:
-- precomputed joins, can be indexed, Tableau optimized
-- higher upfront, lower per-query cost
-- lower cost for full historical analysis

-- vs semantic
-- consistent metrics "active user"; optimize joins based on query; 
-- metric definitions version controlled
-- multiple consumers: Tableau, ? streamlit, ?Hex

-- OBT for performance-critical dashboards
-- metrics for ad hoc analyses, explorations, self-serve analytics
-- ? keep metrics consistent

  -- Production Dashboards → Saved Query Tables (fast, pre-computed)
  -- Ad-hoc Analysis → Direct Semantic Layer (flexible, live)

--  # Define ONCE in semantic layer:
--   - name: avg_programs_per_user
--     agg: average
--     expr: programs_accessed

--   # Used everywhere:
--   - Direct Tableau queries
--   - Saved queries
--   - Python analysis
--   - API endpoints
--   - Excel exports

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
    {{ ref('fct_events') }}
), 
-- TAG TO DO prune column list after investigate how used (ex: resource description)
joined as (
  select
    events.*,
    users.* exclude (user_id)
    districts.* exclude (district_id),
    programs.* exclude (program_id),
    resources.* exclude (resource_id, resource_description)
from
  events 
  inner join users on events.user_id = users.user_id
  inner join districts on users.district_id = districts.district_id
  inner join programs on events.program_id = programs.program_id
  inner join resources on events.resource_id = resources.resource_id
),

final as
(select
  *
from
  joined
{% if target.name == 'dev' %}
  -- Limit number of rows in development environment
  limit 100000
{% endif %}
),

select 
  *
from
  final