with

-- use * with exclude to allow for schema changes made in stg_
programs as (
    select
        * exclude (
            dbt_scd_id,
            dbt_updated_at
        )
    from {{ ref('stg_craft__programs') }}
    qualify row_number() over (
        partition by program_id
        order by dbt_valid_from desc
    ) = 1
),

final as (
    select *
    from programs
)

select *
from
    final
