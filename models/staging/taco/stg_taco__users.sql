with
source_table as (
    select * from {{ ref('snp_taco__users') }}
),

final as (
    -- renaming as many columns have identical names between user, district,
    select
        -- ids
        dbt_utils.surrogate_key(id, dbt_valid_from) as user_valid_from_id,
        id::int as user_id,
        district_id::int as district_id,
        role::string as user_role,
        role_id::int as role_id,
        status::string as user_status,
        username::string as username,        
        grades::string as user_grades,
        other_grades::string as user_other_grades,
        class_id::int as class_id,

        -- identifiers
        sourced_id::string as user_sourced_id,
        identifier::string as user_identifier,
        okta_user_id::string as okta_user_id,
        
        -- onboarding
        invite_status::string as user_invite_status,
        disable_auto_sync::boolean as disable_auto_sync,
        manually_added::boolean as manually_added,
        email_sent::boolean as user_email_sent,
        override_district_auth::boolean as override_district_auth,
       
        -- will likely not be in final model
        contact_email::string as user_contact_email,
        phone::string as phone,
        settings::string as user_settings,
        state_id::int as user_state_id,

        -- timestamps
        date_last_modified::timestamp as date_last_modified,
        -- dbt_scd_id::string as dbt_scd_id,
        -- history columns
        dbt_updated_at::timestamp as dbt_updated_at,
        dbt_valid_from::timestamp as dbt_valid_from,
        dbt_valid_to::timestamp as dbt_valid_to,
        dbt_is_deleted::boolean as dbt_is_deleted
    from source_table
)

select * from final where is_latest;
