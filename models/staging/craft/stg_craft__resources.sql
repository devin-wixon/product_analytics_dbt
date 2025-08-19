with
source_table as (
    select 
        * 
    from 
        {{ source('craft', 'raw_craft__resources') }}
),

final as (
    select
        id::int as resource_id,
        folder_id::int as resource_folder_id,
        program_id::int as resource_program_id,
        author_id::int as resource_author_id,
        type::string as resource_type,
        code::string as resource_code,
        title::string as resource_title,
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
        fts_title::string as resource_fts_title
    from source_table
)

select 
    * 
from 
    final
