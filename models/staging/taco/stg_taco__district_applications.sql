with
source_table as (
    select * from {{ source('taco', 'raw_taco__district_applications') }}
),

final as (
    select
        -- identifiers
        id::int as district_application_id,
        district_id::int as district_id,
        application_id::int as application_id,

        -- attributes
        url::string as url,
        -- public_key::string as public_key,
        -- secret_key::string as secret_key,
        api_prefix::string as api_prefix,
        enabled::boolean as is_enabled,
        abc_group_id::string as abc_group_id,

        -- timestamps
        create_date::timestamp as created_at_utc
    from source_table
)

select * from final
