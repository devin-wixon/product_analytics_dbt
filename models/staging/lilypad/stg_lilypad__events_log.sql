


with source as (


    select
        event_pk,
        server_timestamp::timestamp as server_timestamp,
        client_timestamp::timestamp as client_timestamp,
        user_id::int as user_id,
        session_uuid::string as session_uuid,
        name::string as event_name,
        path::string as event_path,
        event_value::string as event_value,
        -- category, -- leave category out as unreliable
        event_value_human_readable,
        _source_filename,
        _loaded_at_utc


    from {{ source('lilypad', 'raw_lilypad__events_log') }}

)

select * from source