{{ config(
    enabled=false
)}}

with 
users as
(select distinct
    user_id,
    user_role,
    user_grades,
    user_other_grades
from
    {{ ref('dim_users_current') }}
),

events as (
    select
        *
    from
        {{ ref('fct_events') }}
),

resources as (
    select
        *
    from
        {{ ref('dim_resources_current') }}
),

user_daily_activity as (
    select
        users.*,
        events.client_event_date,
        
        -- Program metrics
        count(distinct events.program_id) as n_programs_accessed,

        -- Resource metrics  
        count(distinct events.resource_id) as n_resources_accessed,
        -- TAG OPTIMIZE 
        -- test performance vs dbt_utils.pivot() or Snowflake dynamic pivot 
        {% set resource_types = dbt_utils.get_column_values(
            table=ref('dim_resources_current'),
            column='resource_type',
            order_by='resource_type'
            ) 
        %}

        {% for resource_type in resource_types  %}
        count(distinct case when resources.resource_type = '{{ resource_type }}'
            then resources.resource_id end) as n_{{ resource_type }}_accessed,
        {% endfor %}
        
        -- Event metrics
        count(*) as n_total_events,

        -- TAG TO DO add logic using the loops as in int_events_enriched for event_category values in int_events_enriched columns

        -- boolean metrics
        -- add logic  using the loops as in int_events_enriched for event_category values in int_events_enriched columns


        -- Session metrics: later
        
    from 
        events
    -- only including users with events, and events with known users
    -- TAG TO DO will need to backfill users; ~ 7.4K events.user_id without parent match in users.user_id
    inner join
        users
    on
        events.user_id = users.user_id
    inner join
        resources
    on
        events.resource_id = resources.resource_id
    group by 1,2,3,4,5

{%- if target.name == 'Development' %}
    -- Limit number of rows in development environment
    limit 100000
{%- endif -%}
),

final as (
    select
        *
    from user_daily_activity
)

select
    *
from final