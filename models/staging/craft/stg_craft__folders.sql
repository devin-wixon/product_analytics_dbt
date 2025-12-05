with
source_table as (
    select *
    from
        {{ source('craft', 'raw_craft__folders') }}
),

final as (
    select
        id::int as folder_id,
        name::string as folder_name,
        abreviation::string as folder_abbreviation,
        icon::string as folder_icon,
        program_id::int as folder_program_id,
        order_number::int as folder_order_number,
        type::string as folder_type,
        short_description::string as folder_short_description,
        is_legacy::boolean as is_folder_legacy,
        metatags::string as folder_metatags,
        clone_status::string as folder_clone_status,
        global_order::string as folder_global_order,
        fts_name::string as folder_fts_name,

        -- timestamps
        created_at::timestamp as folder_created_at_utc,
        updated_at::timestamp as folder_updated_at_utc,
        deleted_at::timestamp as folder_deleted_at_utc

    from source_table
)

-- reorder columns
select
    -- core identifiers and attributes
    folder_id,

    -- descriptions and content
    folder_name,
    folder_abbreviation,
    -- boolean flags
    is_folder_legacy,

    -- foreign keys
    folder_program_id,
    folder_order_number,
    folder_type,
    folder_short_description,

    -- other
    folder_icon,
    folder_metatags,
    folder_clone_status,
    folder_global_order,
    folder_fts_name,

    -- timestamps
    folder_created_at_utc,
    folder_updated_at_utc,
    folder_deleted_at_utc

from
    final
