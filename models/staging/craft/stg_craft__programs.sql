with
source_table as (
    select 
        * 
    from 
        {{ ref('snp_craft__programs')}}
),

final as (
    select
        -- identifiers
        id::int as program_id,
        name::string as program_name,

        -- attributes
        description::string as program_description,
        age_group::string as program_age_group,
        supplemental::boolean as is_program_supplemental,
        custom_banner::string as program_custom_banner,
        clone_status::string as program_clone_status,
        type::string as program_type,

        -- dates and timestamps
        deleted_at::date as program_deleted_date,

        -- snapshot columns
        dbt_scd_id,
        dbt_valid_from,
        dbt_valid_to,
        dbt_updated_at,
        dbt_is_deleted

    from source_table
)

select 
    * 
from 
    final
