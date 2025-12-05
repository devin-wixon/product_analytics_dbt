with
source_table as (
    select *
    from
        {{ source('taco', 'raw_taco__schools') }}
),

final as (
    select
        id::int as school_id,
        name::string as school_name,
        district_id::int as district_id,

        -- boolean
        disable_auto_sync::boolean
            as is_school_disable_auto_sync,
        manually_added::boolean as is_school_manually_added,

        -- attributes
        settings::string as school_settings,
        sourced_id::string as school_sourced_id,
        identifier::string as school_identifier,
        -- type_connector: all values are null
        -- type_connector::string as school_type_connector,
        status::string as school_status,

        -- timestamps
        created_at::timestamp as created_at_utc,
        updated_at::timestamp as updated_at_utc
    from source_table
)

select *
from
    final
