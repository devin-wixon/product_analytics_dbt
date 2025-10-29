with

-- use * with exclude to allow for schema changes made in stg_
programs as (
    select
        * exclude (
            dbt_scd_id,
            dbt_valid_from,
            dbt_valid_to,
            dbt_updated_at,
            dbt_is_deleted
        )
    from {{ ref('stg_craft__programs') }}
    where
        dbt_valid_to is null
        and program_deleted_date is null
),

final as (
    select *
    from programs
)

select *
from
    final
