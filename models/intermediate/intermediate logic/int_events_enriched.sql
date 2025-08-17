
-- TAG TO DO Placeholder code with logic; needs debugging and finalizing

with events as (
    select
        event_id,
        server_timestamp,
        client_timestamp,
        user_id,
        session_uuid,
        event_name,
        event_path,
        event_value,
        event_value_human_readable
        -- _source_filename,
        -- _loaded_at_utc
    from {{ ref('stg_lilypad__events_log') }}
    {%- if target.name == 'dev' -%}
    limit 50000
    {%- endif -%}
),

event_metadata as
(select
    *
from
    {{ ref('seed_event_log_metadata') }}

),

events_add_column_info as (
    select
    events.* EXCLUDE (event_path, event_value),
    date(events.server_timestamp) as server_event_date,
    date(events.client_timestamp) as client_event_date,
    event_metadata.event_category as event_category,
        -- clean up
        iff(events.event_path = '' or events.event_path = '/', null, events.event_path)
            as event_path,


        iff(events.event_value = '' or events.event_value = '/', null, events.event_value)
            as event_value,
        -- derive column with what event_value should join to, if anything

        iff(
        -- event value is numeric and joins to an id
            regexp_like(events.event_value, '^[0-9]+$'),
            event_metadata.event_value_joins_to,
            null
        ) as event_value_integer_join_column,

        -- events with non-joining event_value
        -- example: productLaunchOpen event_value is text name not application_id
        iff(
            event_metadata.event_value_not_id is not null,
            events.event_value,
            null
        ) as event_value_text,

        -- case when event_name = 'productLaunchOpen' then event_value else null end as launched_application_name,

        -- router.left events: 
            -- path = route user navigating TO
            -- event_value = route user just LEFT
        case when events.event_name = 'router.left' then event_path else null end as path_entered,
        case when events.event_name = 'router.left' then event_value else null end as path_left,


       -- program_id may be in path but not in event_value
        -- for router.left this will be the program TO, not the one left
        -- if a user copy/pastes a path value that isn't numeric, it will null
        try_cast(
            coalesce(
                case when event_metadata.event_value_joins_to = 'program_id' 
                    and try_cast(events.event_value as integer) 
                    then events.event_value else null end,
                regexp_substr(events.event_path, 'resources/([^/]+)', 1, 1, 'e', 1),
                regexp_substr(events.event_path, 'planner/([^/]+)', 1, 1, 'e', 1),
                regexp_substr(events.event_value, 'resources/([^/]+)', 1, 1, 'e', 1)
            ) as integer
        ) as program_id,

        -- resource_id may be in path but not in event_value
        -- for router.left this will be the resource TO, not the one left
        try_cast(
            coalesce(
                case when event_metadata.event_value_joins_to = 'resource_id' then events.event_value else null end,
                regexp_substr(events.event_path, 'detail/([0-9]+)', 1, 1, 'e', 1),
                regexp_substr(events.event_value, 'detail/([0-9]+)', 1, 1, 'e', 1)
            ) as integer
        ) as resource_id
    from
        events
    left join 
        event_metadata 
    on 
        events.event_name = event_metadata.event_name
),

events_add_pivots as 
(select
    -- do not follow with a comma; conditional comma below
    events_add_column_info.*
    
    -- pivot the other event_value_integer_join_columns using dbt_util.get_column_values
    -- such as framework_id, folder_id, focus_area_id
    {%- set join_columns = dbt_utils.get_column_values(ref('seed_event_log_metadata'), 'event_value_joins_to') -%}
    -- only if a join column exists
    {%- if join_columns -%}
        {%- for join_col in join_columns %}
            {%- if join_col and join_col not in ('program_id', 'resource_id') -%}
            -- Each column gets a comma prefix since they're all middle columns
            , case when event_value_integer_join_column = '{{ join_col }}'
                then try_cast(event_value as integer)
                else null
            end as {{ join_col }}
            {%- endif -%}
        {%- endfor -%}
    {%- endif -%}

    -- dynamic boolean flags: Create is_[category]_event columns
    {%- set event_categories = dbt_utils.get_column_values(
        table=ref('seed_event_log_metadata'),
        column='event_category',
        where="event_category is not null and event_category != ''",
        order_by='event_category'
        )-%}
    -- only if an event category exists
    {%- if event_categories -%}
        {%- for category in event_categories -%}
            --  only add commas between items, not after the final one
            ,(event_category = '{{ category }}') as is_{{ category }}_event
        {%- endfor %}
    {%- endif %}
 from
    events_add_column_info
),

final as 
(select 
   events_add_pivots.*
    -- don't persist ETL
    -- _source_filename,
    -- _loaded_at_utc,
from
    events_add_pivots
)

select
    *
from
    final
