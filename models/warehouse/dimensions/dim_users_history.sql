with

users as (
    select
        *
    from {{ ref('stg_taco__users') }}
),
joined as (
    select
        user_id,
        user_role,
        district_id,
        user_sourced_id,
        is_disable_auto_sync,
        is_manually_added,
        user_invite_status,
        user_grades,
        user_other_grades,
        user_email_sent_at_utc,
        user_updated_at_utc,
        user_created_at_utc,
        dbt_scd_id,
        dbt_valid_from,
        dbt_valid_to,
        dbt_updated_at,
        dbt_is_deleted
    from users
),

final as (
    select
        *
    from joined
)

select
    *
from final
