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
        -- aggregation: user (other user columns are 1:1), date
        users.user_id,
        users.user_role,
        users.user_grades,
        users.user_other_grades
        users.events.client_event_date,
            
        -- Program metrics
        count(distinct events.program_id) as n_programs_accessed_per_user_date,

        -- Resource metrics  
        count(distinct events.resource_id) as n_resources_accessed_per_user_date,
        -- TAG OPTIMIZE OPPORTUNITY
        -- test performance vs dbt_utils.pivot() or Snowflake dynamic pivot 
        {% set resource_types = dbt_utils.get_column_values(
            table=ref('dim_resources_current'),
            column='resource_type',
            order_by='resource_type'
            ) 
        %}

        {% for resource_type in resource_types  %}
        count(distinct case when resources.resource_type = '{{ resource_type }}'
            then resources.resource_id end) as n_{{ resource_type }}_accessed_per_user_date,
        {% endfor %}
        
        -- Event metrics
        count(*) as n_total_events,

        {%- set event_categories = dbt_utils.get_column_values(
            table=ref('seed_event_log_metadata'),
            column='event_category',
            where="event_category is not null and event_category != ''",
            order_by='event_category'
            )-%}
        {%- if event_categories -%}
            {%- for category in event_categories -%}
            ,
            -- counts of event_category events
            count(distinct case when event_category = '{{ category }}'
                then events.event_id end) as n_{{ category }}_events_per_user_date,

            -- boolean: has event_category
            max(event_category = '{{ category }}'
                as user_date_has_{{ category }}_event_per_user_date )
            {%- endfor %}
        {%- endif %}

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
        limit 1000
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