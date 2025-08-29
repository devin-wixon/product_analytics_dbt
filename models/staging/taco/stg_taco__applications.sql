with
source_table as (
    select 
        * 
    from 
        {{ source('taco', 'raw_taco__applications') }}
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

    from source_table
)

select 
    * 
from 
    final
