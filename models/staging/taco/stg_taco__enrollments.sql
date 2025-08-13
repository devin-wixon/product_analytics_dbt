with
source_table as (
    select * from {{ source('taco', 'raw_taco__enrollments') }}
),

final as (
    select
        -- identifiers
        id::int as enrollment_id,
        user_id::int as user_id,

        -- attributes
        role::string as user_role,
        role_id::int as user_role_id,
        class_id::int as class_id,
        school_id::int as school_id,
        district_id::int as district_id,
        
        -- other attributes
        primary::boolean as is_primary,
        status::string as enrollment_status,
        active::boolean as is_enrollment_active,   
           -- other ids
        usersourcedid::string as user_sourced_id,
        classsourcedid::string as class_sourced_id,
        schoolsourcedid::string as school_sourced_id,
        sourced_id::string as enrollment_sourced_id,   

        -- dates and timestamps
        start_date::date as enrollment_start_date,
        end_date::date as enrollment_end_date,
        last_modified::timestamp as last_modified_at_utc


    from source_table
)

select * from final
