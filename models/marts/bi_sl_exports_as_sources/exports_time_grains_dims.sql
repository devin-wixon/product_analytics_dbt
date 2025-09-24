{{
  config(
    description='Unified table containing metrics at multiple time grains and dimension combinations for exports to allow for parameterization (ex: in BI tools). Built from generated semantic layer query exports.'
  )
}}

with

  -- Day grain exports
  day_all as (
      select
          event__metric_time_day__day as date_at_time_grain,
          'day' as time_grain,
          'all' as dim_set,
          'All' as dim_a_label,
          null as dim_b_label,
          'All' as dim_a_value,
          cast(null as varchar) as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_day_all') }}
  ),

  day_program_name as (
      select
          event__metric_time_day__day as date_at_time_grain,
          'day' as time_grain,
          'program_name' as dim_set,
          'Program name' as dim_a_label,
          null as dim_b_label,
          program__program_name as dim_a_value,
          cast(null as varchar) as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_day_program_name') }}
      where program__program_name is not null
  ),

  -- Week grain exports
  week_all as (
      select
          event__metric_time_week__week as date_at_time_grain,
          'week' as time_grain,
          'all' as dim_set,
          'All' as dim_a_label,
          null as dim_b_label,
          'All' as dim_a_value,
          cast(null as varchar) as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_week_all') }}
  ),

  -- Month grain exports
  month_all as (
      select
          event__metric_time_month__month as date_at_time_grain,
          'month' as time_grain,
          'all' as dim_set,
          'All' as dim_a_label,
          null as dim_b_label,
          'All' as dim_a_value,
          cast(null as varchar) as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_month_all') }}
  ),

  month_program_name as (
      select
          event__metric_time_month__month as date_at_time_grain,
          'month' as time_grain,
          'program_name' as dim_set,
          'Program name' as dim_a_label,
          null as dim_b_label,
          program__program_name as dim_a_value,
          cast(null as varchar) as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_month_program_name') }}
      where program__program_name is not null
  ),

  final as (
      select * from day_all
      union all
      select * from day_program_name
      union all
      select * from week_all
      union all
      select * from month_all
      union all
      select * from month_program_name
  )

select *
from final