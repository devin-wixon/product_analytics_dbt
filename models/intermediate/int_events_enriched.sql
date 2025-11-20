{{ config(
    materialized='incremental',
    incremental_strategy='append'
) }}

-- set list of events that will be counted as planner path; excludes modal and launch events
{% set planner_path_events = "(
    'weekly.planner.program.week.filter.close',
    'weekly.planner.program.week.filter.deselect.all',
    'weekly.planner.program.week.filter.open',
    'weekly.planner.program.week.filter.select.all',
    'weekly.planner.program.week.print',
    'weekly.planner.program.week.report.close',
    'weekly.planner.program.week.report.highFive',
    'weekly.planner.program.week.report.open'
)" %}

-- these have specific behaviors, added before automated columns
{%- set manually_added_columns = (
'program_id', 
'resource_id', 
'path_left', 
'path_entered', 
'focus_area_value') 
%}

with events as (
    select
        event_id,
        server_timestamp,
        client_timestamp,
        user_id,
        -- session_uuid is different concept; need to build session with macro
        -- may need this in the future for IP address, device type, etc.
        -- session_uuid,
        event_name,
        -- don't clean; / means dashboard
        event_path,
        event_value,
        event_value_human_readable,
        -- _source_filename,
        -- _loaded_at_utc
        -- batch tracking for incremental loads
        {{ generate_incremental_batch_id() }}
    from {{ ref('stg_lilypad__events_log') }}
    {% if is_incremental() %}
    where date(server_timestamp) > (select max(server_event_date) from {{ this }})
    {% endif %}
    {{ dev_limit(1000) }}

),

event_metadata as
(select
    *
from
    {{ ref('seed_event_log_metadata') }}

),

joined as
(select
    events.*,
    event_metadata.* exclude (event_name)
from
    events
left join 
    event_metadata 
on 
    -- left join ensures completeness
    -- relationship test: event_name FK is a warn status in the events staging model
    events.event_name = event_metadata.event_name
),

-- cleaning and add info for events or values with unique behaviors
events_add_column_info as (
    select
        joined.*,
        date(server_timestamp) as server_event_date,
        date(client_timestamp) as client_event_date,
        -- events with unique behaviors
        case 
            -- router.left events: 
            -- path = route user navigating TO
            -- event_value = route user just LEFT
            when event_name = 'router.left' then event_path 
            when event_name = 'router.enter' then event_value 
            else null 
        end as path_entered,
        case when event_name = 'router.left' then event_value 
            else null 
        end as path_left,
        
        -- this event joins to the focuses_areas.value (source name) text rather than the integer ID
        case when event_name in (
            'weekly.planner.program.week.filter.deselect', 
            'weekly.planner.program.week.filter.select')
                then event_value_human_readable 
            else null 
        end as focus_area_label,

        -- extract info such as week_number from planner paths for specific events
        -- TAG IMPROVEMENT
        -- extract theme vs month_number: join to resource_id when it's not a month number
        -- code is regexp_substr(events.event_path, '^/planner/[^/]+/([^/]+)', 1, 1, 'e', 1)    
        case 
            when event_name in {{ planner_path_events }}
            then try_cast(
                regexp_substr(
                    event_path, '^/planner/[^/]+/[^/]+/([0-9]+)$', 1, 1, 'e', 1
                    ) as integer)
            else null
        end as week_number,

        -- program_id may be in path but not in event_value
        -- for router.left this will be the program TO, not the one left
        -- if a user copy/pastes a path value that isn't numeric, it will null
        try_cast(
            coalesce(
                case when event_value_joins_to = 'program_id' 
                    and try_cast(event_value as integer) 
                    then event_value 
                    else null 
                end,
                regexp_substr(event_path, 'resources/([^/]+)', 1, 1, 'e', 1),
                regexp_substr(event_path, 'planner/([^/]+)', 1, 1, 'e', 1),
                regexp_substr(event_value, 'resources/([^/]+)', 1, 1, 'e', 1)
            ) as integer
        ) as program_id,

        -- resource_id may be in path but not in event_value
        -- for router.left this will be the resource TO, not the one left
        try_cast(
            coalesce(
                case when 
                    event_value_joins_to = 'resource_id' 
                    and try_cast(event_value as integer) 
                    then event_value 
                    else null 
                end,
                regexp_substr(event_path, 'detail/([0-9]+)', 1, 1, 'e', 1),
                regexp_substr(event_value, 'detail/([0-9]+)', 1, 1, 'e', 1)
            ) as integer
    ) as resource_id

    from
        joined
),

events_add_pivots as 
(select
    -- do not follow with a comma; conditional comma below
    events_add_column_info.*,
    
    -- columns that should be an integer and are a foreign key
    {%- set id_join_columns = dbt_utils.get_column_values(
        ref('seed_event_log_metadata'), 'event_value_joins_to') -%}

    -- columns that will be a string and don't join to a key
    {%- set not_id_columns = dbt_utils.get_column_values(
        ref('seed_event_log_metadata'), 'event_value_not_id') %}
    
    -- cast as integer needed for foreign keys
    {%- if id_join_columns -%}
        {%- for col in id_join_columns -%}
            {%- if col and col not in manually_added_columns -%}
                ,
                case
                    when event_value_joins_to = '{{ col }}'
                        then try_cast(event_value as integer)
                    else null
                end as {{ col }}
            {%- endif -%}
        {%- endfor -%}
    {%- endif -%}

  {%- if not_id_columns -%}
      {%- for col in not_id_columns -%}
          {%- if col and col not in manually_added_columns -%}
  ,
          {%- break -%}
          {%- endif -%}
      {%- endfor -%}
  {%- endif -%}

    -- non-foreign key
    -- rest of loop is identical 
    {%- if not_id_columns -%}
        {%- for col in not_id_columns -%}
            {%- if col and col not in manually_added_columns -%}
                ,
                case
                    when event_value_not_id = '{{ col }}'
                        then event_value
                    else null
                end as {{ col }}
          {%- endif -%}
      {%- endfor -%}
  {%- endif -%},

    -- add boolean is_ columns for event categories
    -- code works, not currently used; commented out
    {#
    --   {%- set event_categories = dbt_utils.get_column_values(
    --       table=ref('seed_event_log_metadata'),
    --       column='event_category',
    --       where="event_category is not null and event_category != ''",
    --       order_by='event_category'
    --       )-%}
    --   {%- if event_categories -%}
    --       {%- for category in event_categories -%}
    --             ,
    --             case when event_category = '{{ category }}' then true else false 
    --             end as is_{{ category }}_event
    --       {%- endfor %}
    --   {%- endif %}
    #}
 from
    events_add_column_info
),

final as
(select
   events_add_pivots.* exclude (
        -- event_path,
        -- event_value,
        event_value_joins_to,
        event_value_not_id,
        notes,
        event_trigger,
        handled_as_exception_in_code,
        example_values,
        event_capture_end_date,
        event_capture_start_date
        ),
    {{ assign_event_type('event_category') }} as event_type

    -- don't persist ETL
    -- _source_filename,
    -- _loaded_at_utc
from
    events_add_pivots
)

select
    *
from
    final
