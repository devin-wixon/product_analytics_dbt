with users_history as (
    select
        *
    from {{ ref('dim_users_history') }} as dim_users_history
),

-- dbt_valid_to is sometimes not ever null for backfill deleted users
user_backfill_nonnull_valid_to as (
    select
        user_id
    from users_history
    group by user_id
    -- all records have backfill, and no records have a null dbt_valid_to
    having
        booland_agg(user_invite_status = 'backfill')
        and not boolor_agg(dbt_valid_to is null)
),

users_current as (
    select
        users_history.*
    from users_history
    left join user_backfill_nonnull_valid_to using (user_id)
    where
        users_history.dbt_valid_to is null
        or user_backfill_nonnull_valid_to.user_id is not null
),

final as (
    select
        *
    from users_current
)

select *
from final