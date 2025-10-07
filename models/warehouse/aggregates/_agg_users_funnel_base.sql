with

  user_history as (
      select
          *
      from {{ ref('dim_users_history') }}
  ),

  users_most_recent as (
      select
          *
      from {{ ref('dim_users_most_recent') }}
  ),

  -- Categorize users based on their most recent user_invite_status and dbt_valid_from
  user_categories as (
      select
          user_id,
          user_invite_status as user_current_invite_status,
          case
              -- all backfill users will have dbt_valid_from = 1900-01-01 (unknown entry date)
              when user_invite_status = 'backfill' then 'backfill'
              -- Legacy users: not backfill and dbt_valid_from is 1900-01-01 (unknown entry date)
              when dbt_valid_from = '1900-01-01' then 'legacy'
              when user_invite_status = 'sso' then 'sso'
              else 'username_password'
          end as user_category
      from users_most_recent
  ),

  -- For all users, find first month they had any record
  -- This includes any dbt_valid_from date (including 1900-01-01)
  user_first_record_month as (
      select
          user_id,
          date_trunc('month', min(dbt_valid_from))::date as month_start_date
      from user_history
      group by user_id
  ),

  -- Get user active dates from events
  user_events as (
      select
          user_id,
          event_date,
          row_number() over (partition by user_id order by event_date asc) as user_day_index
      from (
          select distinct
              user_id,
              server_event_date as event_date
          from {{ ref('fct_events') }}
          where user_id is not null
      )
      order by user_id
  ),

  user_has_events as (
      select distinct user_id
      from user_events
  ),

  user_history_enriched as (
      select distinct
          user_history.*,
          user_categories.user_category,
          user_categories.user_current_invite_status,
          user_has_events.user_id is not null as has_user_event
      from user_history
      left join user_categories
          on user_history.user_id = user_categories.user_id
      left join user_has_events
          on user_history.user_id = user_has_events.user_id
  ),

  -- For username_password users: find first time for each status.

  -- Check if user was ever not_invited and get min date
  user_ever_not_invited as (
      select
          user_id,
          -- boolor_agg returns true if any value is true, false if all are false or no rows
          boolor_agg(user_invite_status = 'not_invited') as is_user_not_invited,
          min(case when user_invite_status = 'not_invited' then dbt_valid_from end) as min_user_not_invited_date_to_check,
          -- null out the date when we don't have a real date
          case when min_user_not_invited_date_to_check::date = '1900-01-01' then null else min_user_not_invited_date_to_check end as min_user_not_invited_date
      from user_history_enriched
      where
          -- any user previously username password and now sso could have a record: only consider their sso funnel phases
          user_category = 'username_password'
      group by user_id
  ),
  -- for invited and registered:
  -- if they have any event but no record of the status, count as having had the status with no date

  -- Check if user was ever invited and get min date
  -- user_email_sent_at_utc will be the most recent invite sent, but will often be null (see docs)
  user_ever_invited as (
      select
          user_id,
          case
              when boolor_agg(user_invite_status = 'invited' or user_email_sent_at_utc is not null) then true
              when boolor_agg(has_user_event) then true
              else false
          end as is_user_invited,
          min(case when user_invite_status = 'invited' then dbt_valid_from end) as min_user_invited_date_to_check,
          -- null out the date when we don't have a real date
          coalesce(
            case when min_user_invited_date_to_check::date = '1900-01-01' then null else min_user_invited_date_to_check end,
            min(user_email_sent_at_utc)
            ) as min_user_invited_date
      from user_history_enriched
      where
          user_category = 'username_password'
      group by user_id
  ),


  -- Check if user ever registered (created a password) and get min date
  user_ever_registered as (
      select
          user_id,
          case
              when boolor_agg(user_invite_status = 'registered') then true
              when boolor_agg(has_user_event) then true
              else false
          end as is_user_registered,
          min(case when user_invite_status = 'registered' then dbt_valid_from end) as min_user_register_date_to_check,
          -- null out the date when we don't have a real date
          case when min_user_register_date_to_check::date = '1900-01-01' then null else min_user_register_date_to_check end as min_user_register_date
      from user_history_enriched
      where
          user_category = 'username_password'
      group by user_id
  ),


  user_active_days as (
      select
          user_id,
          min(case when user_day_index = 1 then event_date end) as min_user_active_date,
          min(case when user_day_index = 2 then event_date end) as second_user_active_date,
          boolor_agg(user_day_index = 1) as is_user_active,
          boolor_agg(user_day_index = 2) as is_user_active_two_days,
          count(distinct event_date) as n_user_active_days
      from user_events
      group by user_id
  ),

  -- Combine all user funnel data
  user_funnel_base as (
      select
          user_categories.user_id,
          user_categories.user_category,
          user_categories.user_current_invite_status,
          -- Month start date: null for legacy users, otherwise use first record month or creation month
          case
              when user_categories.user_category in ('legacy', 'backfill') then null
              -- month_start_date will never be null
              else user_first_record_month.month_start_date
          end as month_start_date,

          -- Created flag (all users are created)
          true as is_user_created,

          -- Not invited flag and date;
          -- These will only be created for username_password users and should be null for others
          user_ever_not_invited.is_user_not_invited,
          user_ever_not_invited.min_user_not_invited_date,

          -- Invited flag and date; same logic as above
          user_ever_invited.is_user_invited,
          user_ever_invited.min_user_invited_date,

          -- Registered flag and date; same logic as above
          user_ever_registered.is_user_registered,
          user_ever_registered.min_user_register_date,

          -- Active flag (all user types)
          ifnull(user_active_days.is_user_active, false) as is_user_active,
          user_active_days.min_user_active_date,
          ifnull(user_active_days.is_user_active_two_days, false) as is_user_active_two_days,
          user_active_days.second_user_active_date,
          ifnull(user_active_days.n_user_active_days, 0) as n_user_active_days,

          -- Days between first and second active day
          datediff(
              'day',
              user_active_days.min_user_active_date,
              user_active_days.second_user_active_date
          ) as days_elapsed_first_to_second_active_day

      from user_categories
      left join user_first_record_month
          on user_categories.user_id = user_first_record_month.user_id
      left join user_ever_not_invited
          on user_categories.user_id = user_ever_not_invited.user_id
      left join user_ever_invited
          on user_categories.user_id = user_ever_invited.user_id
      left join user_ever_registered
          on user_categories.user_id = user_ever_registered.user_id
      left join user_active_days
          on user_categories.user_id = user_active_days.user_id
  ),

  final as (
      select
          user_id,
          user_category,
          user_current_invite_status,
          month_start_date,
          is_user_created,
          is_user_not_invited,
          min_user_not_invited_date,
          is_user_invited,
          min_user_invited_date,
          is_user_registered,
          min_user_register_date,
          is_user_active,
          min_user_active_date,
          is_user_active_two_days,
          second_user_active_date,
          n_user_active_days,
          days_elapsed_first_to_second_active_day
      from user_funnel_base
  )

  select *
  from final