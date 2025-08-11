with
source_table as (
    select * from {{ source('taco', 'raw_taco__enrollments') }}
),

final as (
    select
        -- identifiers
        id::int as enrollment_id,
        usersourcedid::string as user_sourced_id,
        classsourcedid::string as class_sourced_id,
        schoolsourcedid::string as school_sourced_id,
        usersourceid::string as user_source_id,

        -- attributes
        role::string as role,
        user_id::int as user_id,
        class_id::int as class_id,
        primary::boolean as is_primary,
        status::string as status,
        active::boolean as is_active,
        district_id::int as district_id,
        sourced_id::string as sourced_id,
        school_id::int as school_id,
        role_id::int as role_id,
        
        -- dates and timestamps
        start_date::date as start_date,
        end_date::date as end_date,
        last_modified::timestamp as last_modified_at_utc
    from source_table
)

select * from final
