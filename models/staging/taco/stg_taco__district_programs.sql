with
source_table as (
    select *
    from
        {{ ref('snp_taco__district_programs') }}
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
    date(expiration_date::int) as expiration_date,
    updated_at::timestamp as updated_at_utc,
    created_at::timestamp as created_at_utc,

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
