with
source_table as (
    select * from {{ source('craft', 'raw_craft__resources') }}
),

final as (
    select
        id::int as resource_id,
        folder_id::int as folder_id,
        program_id::int as program_id,
        author_id::int as author_id,
        type::string as resource_type,
        code::string as resource_code,
        title::string as resource_title,
        description::string as resource_description,
        file_url::string as file_url,
        section_title::string as section_title,
        link::string as link,
        is_legacy::boolean as is_legacy,
        short_description::string as short_description,
        order_number::int as order_number,
        thumbnail_mobile_url::string as thumbnail_mobile_url,
        thumbnail_web_url::string as thumbnail_web_url,
        downloadable::boolean as is_downloadable,
        provider_id::int as provider_id,
        is_public::boolean as is_public,
        uuid::string as uuid,
        focus_area::string as focus_area,
        publication_status::string as publication_status,
        publication_origin_id::int as publication_origin_id,
        focus_area_id::int as focus_area_id,
        sub_focus_area_id::int as sub_focus_area_id,
        estimated_time::int as estimated_time,
        physical_reference::string as physical_reference,
        physical_page_number::int as physical_page_number,
        fts_title::string as fts_title
    from source_table
)

select * from final
