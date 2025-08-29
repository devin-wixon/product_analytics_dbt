with
source_table as (
    select 
        * 
    from 
        {{ ref('snp_taco__applications')}}
),

final as (
    select
        -- ids
        id::int as application_id,

        -- attributes
        name::string as application_name,
        meta_code::string as application_meta_code,
        type::string as application_type,

        -- flags
        use_memberships::boolean as is_application_use_memberships,
        enabled::boolean as is_application_enabled,
        teachers_only::boolean as is_application_teachers_only,

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
