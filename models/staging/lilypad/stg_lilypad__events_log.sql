
{{ config(
    materialized='incremental',
    strategy='append',
) }}


with source as (


    select
        event_pk,
        server_timestamp,
        client_timestamp,
        user_id,
        session_uuid,
        name as event_name,
        path as event_path,
        event_value,
        category,
        event_value_human_readable,
        _source_filename,
        _loaded_at_utc


    from {{ source('lilypad', 'raw_lilypad__events_log') }}

    {% if is_incremental() %}
      where _loaded_at_utc > (select max(_loaded_at_utc) from {{ this }})
    {% endif %}

)

select * from source