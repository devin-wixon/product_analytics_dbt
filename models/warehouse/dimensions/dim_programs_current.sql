with

-- use * with exclude to allow for schema changes made in stg_
programs as (
    select
        * exclude (
            dbt_valid_from,
            dbt_valid_to,
            dbt_is_deleted
        )
    from {{ ref('dim_programs_most_recent') }}
    where
        not(is_program_deleted)
),

final as (
    select *
    from programs
)

select *
from
    final
