with
source_table as (
    select *
    from
        {{ ref('snp_taco__districts') }}
),

final as (
    select
        -- ids
        id::int as district_id,
        -- parent is always 1; not persisting
        -- parent_district_id::int as parent_district_id,
        -- role_id is always 2; not persisting
        -- role_id::int as role_id,

        -- attributes
        name::string as district_name,
        address::string as district_address,
        city::string as district_city,
        state::string as district_state,
        state_international::string as district_state_international,
        type::string as district_type,
        -- curriculum is always null; don't persist
        -- curriculum::string as district_curriculum,
        enabled::boolean as is_district_enabled,
        -- tags::string as district_tags,

        -- settings and configuration
        website_slug::string as district_website_slug,
        try_parse_json(settings)::variant as district_settings,
        try_parse_json(general_settings)::variant as district_general_settings,
        auto_sync::boolean as is_district_auto_sync,

        -- identifiers
        sourced_id::string as district_sourced_id,
        identifier::string as district_identifier,
        sales_force_id::string as district_sales_force_id,
        mas_id::string as district_mas_id,
        sage_id::string as district_sage_id,

        -- timestamps
        -- Convert string timestamps to proper timestamp format if needed
        last_sync::timestamp as district_last_sync_utc,
        date_last_modified::timestamp as district_last_modified_at_utc,
        roster_file_created_at::timestamp as roster_file_created_at_utc,
        auto_rostering_checked_at::timestamp as auto_rostering_checked_at_utc,

        -- snapshot columns
        dbt_scd_id,
        dbt_valid_from,
        dbt_valid_to,
        dbt_updated_at,
        dbt_is_deleted::boolean as dbt_is_deleted
    from source_table
)

select *
from
    final
