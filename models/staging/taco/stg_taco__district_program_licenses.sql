with
source_table as (
    select *
    from
        {{ source('taco', 'raw_taco__district_program_licenses') }}
),

final as (
    select
        -- ids
        id::int as district_program_license_id,
        district_id::int as district_id,
        program_id::int as program_id,

        -- attributes
        license::string as license,
        quantity_licenses::int as quantity_licenses,
        -- sales_record::string as sales_record
        
        -- expiration date is a unix timestamp, but
        --  all times are 5pm; convert to date
        date(expiration_date::int) as expiration_date
        
        -- timestamps
        created_at as created_at_utc,
        updated_at as updated_at_utc,
        deleted_at as deleted_at_utc,


    from source_table
)

select *
from
    final
