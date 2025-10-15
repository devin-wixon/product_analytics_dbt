with
source_table as (
    select *
    from
        {{ ref('snp_taco__district_applications') }}
),

final as (
    select
        -- identifiers
        id::int as district_application_id,
        district_id::int as district_id,
        application_id::int as application_id,

        -- attributes
        enabled::boolean as is_enabled,
        -- api_key_id::varchar as api_key_id,
        -- api_key::varchar as api_key,

        -- timestamps
        create_date::timestamp as created_at_utc,

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
