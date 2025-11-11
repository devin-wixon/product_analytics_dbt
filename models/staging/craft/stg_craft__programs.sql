with
source_table as (
    select *
    from
        {{ ref('snp_craft__programs') }}
),

final as (
    select
        id::int as program_id,
        name::string as program_name,

        description::string as program_description,
        age_group::string as program_age_group,
        supplemental::boolean as is_program_supplemental,
        custom_banner::string as program_custom_banner,
        clone_status::string as program_clone_status,
        type::string as program_type,
        tags::string as program_tags,
        district_auto_add::boolean as is_program_district_auto_add,
        language::string as program_language,
        license_type::string as program_license_type,
        release_date::integer as program_release_year,
        phase::string as program_phase,
        market_specific::string as program_market_specific,
        is_demo::boolean as is_program_demo,
        order_number::integer as program_order_number,

        deleted_at::date as program_deleted_date,
        dbt_scd_id,

        -- snapshot columns
        dbt_valid_from,
        dbt_valid_to,
        dbt_updated_at,
        dbt_is_deleted::boolean as dbt_is_deleted,
        dbt_is_deleted
        or program_deleted_date is not null as is_program_deleted

    from source_table
)

-- reorder columns
select
    -- core attributes
    program_id,
    program_name,
    program_description,
    program_type,
    is_program_deleted,

    -- classification and metadata
    program_age_group,
    program_language,
    program_license_type,
    program_phase,
    program_market_specific,
    program_tags,
    program_clone_status,
    program_custom_banner,
    program_release_year,
    program_order_number,

    -- boolean flags
    is_program_supplemental,
    is_program_district_auto_add,
    is_program_demo,

    -- date and time
    program_deleted_date,

    -- dbt snapshot columns
    dbt_scd_id,
    dbt_updated_at,
    dbt_valid_from,
    dbt_valid_to,
    dbt_is_deleted

from
    final
