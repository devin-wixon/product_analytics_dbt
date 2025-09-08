with
source_table as (
    select *
    from
        {{ ref('snp_taco__enrollments') }}
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
        -- status & active are not meaningful; removed after staging layer
        status::string as enrollment_status,
        active::boolean as is_enrollment_active,
        -- other ids
        usersourcedid::string as user_sourced_id,
        classsourcedid::string as class_sourced_id,
        schoolsourcedid::string as school_sourced_id,
        sourced_id::string as enrollment_sourced_id,

        -- dates and timestamps
        -- start & end dates are not meaningful; removed after staging layer
        start_date::date as enrollment_start_date,
        end_date::date as enrollment_end_date,
        created_at::timestamp as created_at_utc,
        updated_at::timestamp as updated_at_utc,


        -- snapshot columns
        dbt_scd_id,
        dbt_valid_from,
        dbt_valid_to,
        dbt_updated_at,
        dbt_is_deleted::boolean as dbt_is_deleted

    from source_table
)

select *
from
    final
