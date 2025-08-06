with events as 
(
    select
        event_pk,
        server_timestamp,
        client_timestamp,
        user_id,
        session_uuid,
        event_name,
        event_path,
        event_value,
        category,
        event_value_human_readable,
        _source_filename,
        _loaded_at_utc
    from {{ ref('stg_lilypad__events_log') }}
),

events_add_columns_to_join as
    events.* exclude (event_path),
    if(event_path = '' OR event_path = '/', NULL, event_path) AS event_path,
    if(event_value = '' OR event_value = '/', NULL, event_value) AS event_value,

    -- derived column for join key based on numeric event_value
    if(
        -- event value is numeric
        regexp_like(event_value, '^[0-9]+$'),
        case 
        -- these event names will have an event_value that joins to program_id
            when name in (
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
            
             -- these event names will have an event_value that joins to resource_id
            when name in (
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
            else null
        end,
        null
    ) as event_value_integer_join_column,
    
    -- path will give more program_id values than event_value, but sometimes event_value has the program when path is null
    cast(
        coalesce(
            case 
            when event_value_integer_join_column = 'program_id' then event_value 
            else null 
            end,
            regexp_substr(events.path, 'resources/([^/]+)', 1, 1, 'e', 1),
            regexp_substr(events.path, 'planner/([^/]+)', 1, 1, 'e', 1),
            regexp_substr(events.event_value, 'resources/([^/]+)', 1, 1, 'e', 1)
        ) as integer
    ) as program_id

    -- path will give more resource_id values than event_value, but sometimes event_value has the resource when path is null

    cast(
        coalesce(
            case 
            when event_value_integer_join_column = 'resource_id' then event_value 
            else null 
            end,
            regexp_substr(events.path, 'detail/([0-9]+)', 1, 1, 'e', 1),
            regexp_substr(events.event_value, 'detail/([0-9]+)', 1, 1, 'e', 1)
        ) as integer
    ) as resource_id


      
, events_add_booleans as 
(select
    events_joins.*,
    event_name = 'auth.login' as is_login_event,
    event_name in ('weekly.planner.modal.program.week.select', 'weekly.planner.modal.lastWeeklyPlanner.open') as is_planner_open_event

from
    events_add_columns_to_join as events_joins
)

select
    *
from
    events_add_booleans

-- regexp_like(path,'^/planner/') as is_planner_event, -- TAG TO DO need to exclude the modal events
-- if join to resources here and add resource_type = 
--    resource_type='document', event_client_date as is_resource_document_event,
--     resource_type='activity', event_client_date as is_resource_activity_event,
--     resource_type='book', event_client_date as is_resource_book_event,
--     resource_type='audio', event_client_date as is_resource_audio_event,
--     resource_type='video', event_client_date as is_resource_video_event,
--     resource_type = 'document' 
--     and event_name = 'router.enter') as n_document_router_enter_events,... etc
-- if join to program then...
-- user_program_agg.program_name in ('Yogapalooza', 'Inclusive Classroom') as is_yogapalooza_or_inclusive_classroom_program_event,