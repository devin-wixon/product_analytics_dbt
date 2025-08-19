{{ config(
    enabled = False
    )
}}

with 
users as
(select
    *
from
    {{ ref('dim_users_current') }}
),

events as (
    select
        *
    from
        {{ ref('fct_events') }}
),

user_daily_activity as (
    select
        users.user_id,
        users.user_role,
        users.user_grades,
        users.user_other_grades,
        events.client_event_date,
        
        -- Program metrics
        count(distinct events.program_id) as n_programs_accessed,
        count(distinct case when events.is_planner_open_event then events.program_id end) as n_programs_with_planner_launch,
        count(distinct case when is_application_launch_event then event_value end) as n_applications_launched

        -- Resource metrics  
        count(distinct events.resource_id) as n_resources_accessed,
        {% for resource_type in dbt_utils.get_column_values(ref('dim_resources_current'), 'resource_type') %}
            count(distinct case when events.resource_type = '{{ resource_type }}' then events.resource_id end) as n_{{ resource_type }}_accessed,
        {% endfor %}

        
        -- Event metrics
        count(*) as n_total_events,

        -- add logic later using the loops as in int_events_enriched for event_category values in int_events_enriched columns

        -- boolean metrics
        -- add logic later using the loops as in int_events_enriched for event_category values in int_events_enriched columns


        -- Session metrics: later
        
    from 
        events
    -- only including users with events, and events with known users
    -- TAG TO DO will need to backfill users; ~ 7.4K events.user_id without parent match in users.user_id
    inner join
        users
    where user_id is not null
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