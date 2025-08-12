with
source_table as (
    select * from {{ source('taco', 'raw_taco__enrollments') }}
),

final as (
    select
        -- identifiers
        id::int as enrollment_id,
   
        -- attributes

        user_id::int as user_id,
        -- enrolled in
        role::string as user_role,
        class_id::int as class_id,
        district_id::int as district_id,
        school_id::int as school_id,
        role_id::int as role_id,
        
        -- other attributes
        primary::boolean as is_primary,
        status::string as status,
        active::boolean as is_active,   
        
        -- dates and timestamps
        start_date::date as start_date,
        end_date::date as end_date,
        last_modified::timestamp as last_modified_at_utc,

        -- other ids
        usersourcedid::string as user_sourced_id,
        classsourcedid::string as class_sourced_id,
        schoolsourcedid::string as school_sourced_id,
        usersourceid::string as user_source_id,
        sourced_id::string as sourced_id
    from source_table
)

select * from final
