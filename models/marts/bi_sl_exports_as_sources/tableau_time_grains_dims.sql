{{
  config(
    materialized='table',
    description='Unified table containing metrics at multiple time grains and dimension combinations for Tableau parameterization'
  )
}}

with

  -- DAY GRAIN QUERIES --
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
      from
          {{ source('exports', 'qexptbl_day_program_name') }}
      where
          program__program_name is not null
  ),

  day_resource_type as (
      select
          event__metric_time_day__day as date_at_time_grain,
          'day' as time_grain,
          'resource_type' as dim_set,
          'Resource type' as dim_a_label,
          null as dim_b_label,
          resource__resource_type as dim_a_value,
          cast(null as varchar) as dim_b_value,
          n_active_users,
          n_events
      from
          {{ source('exports', 'qexptbl_day_resource_type') }}
      where
          resource__resource_type is not null
  ),

  -- WEEK GRAIN QUERIES --
  week_program_name as (
      select
          event__metric_time_week__week as date_at_time_grain,
          'week' as time_grain,
          'program_name' as dim_set,
          'Program name' as dim_a_label,
          null as dim_b_label,
          program__program_name as dim_a_value,
          cast(null as varchar) as dim_b_value,
          n_active_users,
          n_events
      from
          {{ source('exports', 'qexptbl_week_program_name') }}
      where
          program__program_name is not null
  ),

  week_resource_type as (
      select
          event__metric_time_week__week as date_at_time_grain,
          'week' as time_grain,
          'resource_type' as dim_set,
          'Resource type' as dim_a_label,
          null as dim_b_label,
          resource__resource_type as dim_a_value,
          cast(null as varchar) as dim_b_value,
          n_active_users,
          n_events
      from
          {{ source('exports', 'qexptbl_week_resource_type') }}
      where
          resource__resource_type is not null
  ),

  -- MONTH GRAIN QUERIES (EXISTING) --
  month_program as (
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
      from
          {{ source('exports', 'qexptbl_month_program') }}
      where
          program__program_name is not null
  ),

  month_resource_type as (
      select
          event__metric_time_month__month as date_at_time_grain,
          'month' as time_grain,
          'resource_type' as dim_set,
          'Resource type' as dim_a_label,
          null as dim_b_label,
          resource__resource_type as dim_a_value,
          cast(null as varchar) as dim_b_value,
          n_active_users,
          n_events
      from
          {{ source('exports', 'qexptbl_month_resource_type') }}
      where
          resource__resource_type is not null
  ),

  month_program_resource_type as (
      select
          event__metric_time_month__month as date_at_time_grain,
          'month' as time_grain,
          'program__resource_type' as dim_set,
          'Program name' as dim_a_label,
          'Resource type' as dim_b_label,
          program__program_name as dim_a_value,
          resource__resource_type as dim_b_value,
          n_active_users,
          n_events
      from
          {{ source('exports', 'qexptbl_month_program_resource_type') }}
      where
          program__program_name is not null or resource__resource_type is not null
  ),

  -- Two-way combination example
  day_program_resource_type as (
      select
          event__metric_time_day__day as date_at_time_grain,
          'day' as time_grain,
          'program__resource_type' as dim_set,
          'Program name' as dim_a_label,
          'Resource type' as dim_b_label,
          program__program_name as dim_a_value,
          resource__resource_type as dim_b_value,
          n_active_users,
          n_events
      from
          {{ source('exports', 'qexptbl_day_program_name_resource_type') }}
      where
          program__program_name is not null or resource__resource_type is not null
  ),

  final as (
      select * from day_program_name
      union all
      select * from day_resource_type
      union all
      select * from week_program_name
      union all
      select * from week_resource_type
      union all
      select * from month_program
      union all
      select * from month_resource_type
      union all
      select * from month_program_resource_type
      union all
      select * from day_program_resource_type
  )

select *
from final