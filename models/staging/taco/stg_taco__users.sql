with
source_table as (
    select * from {{ source('taco', 'raw_taco__users') }}
),

final as (
    select
        -- ids
        {{ dbt_utils.generate_surrogate_key(
            ['id']
        )}} as user_sk,
        id::int as user_id,
        district_id::int as district_id,
        role::string as user_role,
        
        -- attributes
        status::string as user_status,
        grades::string as user_grades,
        other_grades::string as user_other_grades,
        
        -- identifiers
        sourced_id::string as user_sourced_id,
        identifier::string as user_identifier,
        
        -- flags
        disable_auto_sync::boolean as disable_auto_sync,
        manually_added::boolean as manually_added,
        invite_status::string as user_invite_status,
        
        -- timestamps
        email_sent::timestamp as email_sent_utc,
        date_last_modified::timestamp as date_last_modified_utc
        -- deleted_at::timestamp as deleted_at_utc -- null in all columns of source 080825
    from source_table
)

select * from final
