with
source_table as (
    select * from {{ source('taco', 'raw_taco__district_application_licenses') }}
),

final as (
    select
        -- identifiers
        id::int as district_application_license_id,
        district_id::int as district_id,
        application_id::int as application_id,

        -- attributes
        license::string as license,
        quantity_licenses::int as quantity_licenses,
        -- sales_record::string as sales_record

        -- timestamps
        date(expiration_date::int) as expiration_dat_dt,
        created_at as created_at_utc,
        updated_at as updated_at_utc,
        deleted_at as deleted_at_utc
    from source_table
)

select * from final
