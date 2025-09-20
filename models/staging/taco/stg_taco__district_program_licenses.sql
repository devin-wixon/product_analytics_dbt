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
        
        
        -- timestamps
        created_at::timestamp as created_at_utc,
        updated_at::timestamp as updated_at_utc,
        deleted_at::timestamp as deleted_at_utc,
       expiration_date::timestamp as expiration_at_utc

    from source_table
)

select *
from
    final
