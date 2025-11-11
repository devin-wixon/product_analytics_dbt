with
source_table as (
    select *
    from
        {{ ref('snp_craft__resources') }}
),

final as (
    select
        id::int as resource_id,
        folder_id::int as resource_folder_id,
        program_id::int as resource_program_id,
        author_id::int as resource_author_id,

        code::string as resource_code,
        description::string as resource_description,
        file_url::string as resource_file_url,
        section_title::string as resource_section_title,
        link::string as resource_link,
        is_legacy::boolean as is_resource_legacy,
        short_description::string as resource_short_description,
        order_number::int as resource_order_number,
        thumbnail_mobile_url::string as resource_thumbnail_mobile_url,
        thumbnail_web_url::string as resource_thumbnail_web_url,
        downloadable::boolean as is_resource_downloadable,
        provider_id::int as resource_provider_id,
        is_public::boolean as is_resource_public,
        uuid::string as resource_uuid,
        focus_area::string as resource_focus_area,
        publication_status::string as resource_publication_status,
        publication_origin_id::int as resource_publication_origin_id,
        focus_area_id::int as resource_focus_area_id,
        sub_focus_area_id::int as resource_sub_focus_area_id,
        estimated_time::int as resource_estimated_time,
        physical_reference::string as resource_physical_reference,
        physical_page_number::int as resource_physical_page_number,
        fts_title::string as resource_fts_title,
        cloned_from::int as resource_cloned_from,

        -- timestamps
        updated_at::timestamp as resource_updated_at_utc,
        deleted_at::timestamp as resource_deleted_at_utc,
        created_at::timestamp as resource_created_at_utc,

        -- snapshot columns
        dbt_scd_id,
        dbt_valid_from,
        dbt_valid_to,
        dbt_updated_at,
        dbt_is_deleted::boolean as dbt_is_deleted,
        dbt_is_deleted or resource_deleted_at_utc is not null as is_resource_deleted,
        trim(title::string) as resource_title,
        -- replace spaces and hypens in resource type and make lowercase
        lower(
            replace(
                replace(type::string, ' ', '_'),
                '-', '_'
            )
        ) as resource_type
    from source_table
)

-- reorder columns
select
    -- core identifiers and attributes
    resource_id,
    resource_uuid,
    resource_code,
    resource_title,
    resource_type,
    is_resource_deleted,

    -- descriptions and content
    resource_description,
    resource_short_description,
    resource_section_title,
    resource_fts_title,

    -- classification and metadata
    resource_focus_area,
    resource_publication_status,
    resource_order_number,
    resource_estimated_time,
    resource_physical_reference,
    resource_physical_page_number,

    -- boolean flags
    is_resource_legacy,
    is_resource_downloadable,
    is_resource_public,

    -- foreign keys
    resource_folder_id,
    resource_program_id,
    resource_author_id,
    resource_provider_id,
    resource_publication_origin_id,
    resource_focus_area_id,
    resource_sub_focus_area_id,

    -- urls and links
    resource_file_url,
    resource_link,
    resource_thumbnail_mobile_url,
    resource_thumbnail_web_url,

    -- timestamps
    resource_created_at_utc,
    resource_updated_at_utc,
    resource_deleted_at_utc,

    -- dbt snapshot columns
    dbt_scd_id,
    dbt_updated_at,
    dbt_valid_from,
    dbt_valid_to,
    dbt_is_deleted

from
    final
