with
source_table as (
    select 
        * 
    from 
        {{ source('taco', 'raw_taco__districts_programs') }}
),

final as (
    select
        -- ids
        -- no key in source; generating
        {{ dbt_utils.generate_surrogate_key(
            ['district_id', 'program_id']) }} as district_program_id_sk,
        district_id::int as district_id,
        program_id::int as program_id,

        -- attributes
        enabled::boolean as is_enabled,

        -- timestamps or dates
        -- change unix timestamp (which is always 5pm) to date
        date(expiration_date::int) as expiration_date
    from source_table
)

select 
    * 
from 
    final
