

-- TAG TO DO Placeholder code with logic; needs debugging and finalizing

with events as (
    select
        event_pk,
        server_timestamp,
        client_timestamp,
        user_id,
        session_uuid,
        event_name,
        event_path,
        event_value,
        event_value_human_readable,
        _source_filename,
        _loaded_at_utc
    from {{ ref('stg_lilypad__events_log') }}
),

events_add_columns_to_join as (
    select
    events.* EXCLUDE (event_path, event_value),
        -- clean up
        iff(event_path = '' or event_path = '/', null, event_path)
            as event_path,


        iff(event_value = '' or event_value = '/', null, event_value)
            as event_value,
        -- derive column with what event_value should join to, if anything

        iff(
        -- event value is numeric
            regexp_like(event_value, '^[0-9]+$'),
            case
                -- event names with event_value that joins to program_id
                when event_name in (
                    'weekly.planner.modal.lastWeeklyPlanner.open',
                    'weekly.planner.modal.program.select',
                    'weekly.planner.modal.program.deselect',
                    'weekly.planner.modal.program.theme.select',
                    'weekly.planner.modal.program.theme.deselect',
                    'weekly.planner.modal.program.week.select',
                    'weekly.planner.program.week.complete',
                    'weekly.planner.program.week.report.open',
                    'weekly.planner.program.week.report.close',
                    'weekly.planner.program.week.print',
                    'weekly.planner.program.week.filter.open',
                    'weekly.planner.program.week.filter.close',
                    'weekly.planner.program.week.filter.select.all',
                    'weekly.planner.program.week.filter.deselect.all',
                    'weekly.planner.program.week.report.highFive',
                    'weekly.planner.modal.close'
                ) then 'program_id'

                -- event names with event_value that joins to resource_id
                when event_name in (
                    'weekly.planner.program.week.card.open',
                    'weekly.planner.program.week.card.toDo',
                    'weekly.planner.program.week.card.complete',
                    'weekly.planner.program.week.card.skip',
                    'weekly.planner.program.week.card.needToRevisit',
                    'weekly.planner.resource.page.card.complete',
                    'weekly.planner.resource.page.card.skip',
                    'weekly.planner.resource.page.card.needToRevisit',
                    'download',
                    'openInNewTab',
                    'print',
                    'fullscreen',
                    'pdf.changePage',
                    'pdf.changeZoom',
                    'playlist.changeSong',
                    'playlist.autoPlay',
                    'media.start',
                    'media.play',
                    'media.pause',
                    'media.seek',
                    'media.changeVolume'
                ) then 'resource_id'
                -- TAG TO DO what is this joining to? metadata says: "Resource Filter id"
                -- doesn't seem to be folder_id or resource_id
                when event_name in (
                    'program.resource.accordion.open',
                    'program.resource.accordion.close'
                ) then 'xxx'
                -- TAG TO DO what is this joining to? metadata says: "Resource Filter id"
                -- folder_id isn't right. sometimes it is, sometimes it isn't
                when event_name in (
                    'program.resource.accordion.list.close',
                    'program.resource.accordion.list.open'
                ) then 'xxx'
                -- TAG TO DO Confirm this, then add framework_id as a column below
                when event_name in 
                    ('weekly.planner.program.week.filter.change.framework'
                ) then 'framework_id'
                -- TAG TO DO what is this joining to? metadata says: "focus area type"
                -- TAG TO DO then add focus_area_id as a column below as needed
                when event_name in 
                    ('weekly.planner.program.week.filter.deselect',
                    'weekly.planner.program.week.filter.select'
                ) then 'xxx'
                -- TAG TO DO what is this joining to? metadata says: "domain id"
                -- TAG TO DO then add domain_id as a column below as needed
                when event_name in (
                    'weekly.planner.program.week.report.skill.group.close',
                    'weekly.planner.program.week.report.skill.group.open'
                ) then 'xxx'
            end,
            null
            -- TAG TO DO repeat for all event_value: framework_id, focus_area_id, folder_id, etc.
        ) as event_value_integer_join_column,

        -- events with odd behaviors

        -- productLaunchOpen event_value is text name not application_id
        case when event_name = 'productLaunchOpen' then event_value else null end as launched_application_name,

        -- router.left events: 
            -- path = route user navigating TO
            -- event_value = route user just LEFT
        case when event_name = 'router.left' then event_path else null end as path_entered,
        case when event_name = 'router.left' then event_value else null end as path_left,


       -- program_id may be in path but not in event_value
        -- for router.left this will be the program TO, not the one left
        -- if a user copy/pastes a path value that isn't numeric, it will null
        try_cast(
            coalesce(
                case when event_value_integer_join_column = 'program_id' then event_value else null end,
                regexp_substr(events.event_path, 'resources/([^/]+)', 1, 1, 'e', 1),
                regexp_substr(events.event_path, 'planner/([^/]+)', 1, 1, 'e', 1),
                regexp_substr(events.event_value, 'resources/([^/]+)', 1, 1, 'e', 1)
            ) as integer
        ) as program_id,

        -- resource_id may be in path but not in event_value
        -- for router.left this will be the resource TO, not the one left
        try_cast(
            coalesce(
                case when event_value_integer_join_column = 'resource_id' then event_value else null end,
                regexp_substr(events.event_path, 'detail/([0-9]+)', 1, 1, 'e', 1),
                regexp_substr(events.event_value, 'detail/([0-9]+)', 1, 1, 'e', 1)
            ) as integer
        ) as resource_id

    from
        events
),

events_add_booleans as (
    select
        events_joins.*,
        events_joins.event_name = 'auth.login' as is_login_event,
        events_joins.event_name in (
            'weekly.planner.modal.program.week.select',
            'weekly.planner.modal.lastWeeklyPlanner.open'
        ) as is_planner_open_event

    from
        events_add_columns_to_join as events_joins
), 

final as 
(select 
    *
from
    events_add_booleans
)

select
    *
from
    final

-- regexp_like(event_path,'^/planner/') as is_planner_event, -- TAG TO DO need to exclude the modal events