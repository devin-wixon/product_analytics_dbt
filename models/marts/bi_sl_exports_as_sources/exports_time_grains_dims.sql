{{
  config(
    description='Unified table containing metrics at multiple time grains and dimension combinations for exports to allow for parameterization (ex: in BI tools). Built from generated semantic layer query exports.'
  )
}}

with

  -- DAY GRAIN EXPORTS (16 dimension combinations)

  -- All (no dimensions)
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

  -- Single dimensions
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
      from {{ source('exports', 'qexptbl_day_resource_type') }}
      where resource__resource_type is not null
  ),

  day_district_name as (
      select
          event__metric_time_day__day as date_at_time_grain,
          'day' as time_grain,
          'district_name' as dim_set,
          'District name' as dim_a_label,
          null as dim_b_label,
          district__district_name as dim_a_value,
          cast(null as varchar) as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_day_district_name') }}
      where district__district_name is not null
  ),

  day_district_type as (
      select
          event__metric_time_day__day as date_at_time_grain,
          'day' as time_grain,
          'district_type' as dim_set,
          'District type' as dim_a_label,
          null as dim_b_label,
          district__district_type as dim_a_value,
          cast(null as varchar) as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_day_district_type') }}
      where district__district_type is not null
  ),

  day_application_name as (
      select
          event__metric_time_day__day as date_at_time_grain,
          'day' as time_grain,
          'application_name' as dim_set,
          'Application name' as dim_a_label,
          null as dim_b_label,
          event__application_name as dim_a_value,
          cast(null as varchar) as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_day_application_name') }}
      where event__application_name is not null
  ),

  -- Two-way combinations
  day_program_name_resource_type as (
      select
          event__metric_time_day__day as date_at_time_grain,
          'day' as time_grain,
          'program_name_resource_type' as dim_set,
          'Program name' as dim_a_label,
          'Resource type' as dim_b_label,
          program__program_name as dim_a_value,
          resource__resource_type as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_day_program_name_resource_type') }}
      where program__program_name is not null and resource__resource_type is not null
  ),

  day_program_name_district_name as (
      select
          event__metric_time_day__day as date_at_time_grain,
          'day' as time_grain,
          'program_name_district_name' as dim_set,
          'Program name' as dim_a_label,
          'District name' as dim_b_label,
          program__program_name as dim_a_value,
          district__district_name as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_day_program_name_district_name') }}
      where program__program_name is not null and district__district_name is not null
  ),

  day_program_name_district_type as (
      select
          event__metric_time_day__day as date_at_time_grain,
          'day' as time_grain,
          'program_name_district_type' as dim_set,
          'Program name' as dim_a_label,
          'District type' as dim_b_label,
          program__program_name as dim_a_value,
          district__district_type as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_day_program_name_district_type') }}
      where program__program_name is not null and district__district_type is not null
  ),

  day_program_name_application_name as (
      select
          event__metric_time_day__day as date_at_time_grain,
          'day' as time_grain,
          'program_name_application_name' as dim_set,
          'Program name' as dim_a_label,
          'Application name' as dim_b_label,
          program__program_name as dim_a_value,
          event__application_name as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_day_program_name_application_name') }}
      where program__program_name is not null and event__application_name is not null
  ),

  day_resource_type_district_name as (
      select
          event__metric_time_day__day as date_at_time_grain,
          'day' as time_grain,
          'resource_type_district_name' as dim_set,
          'Resource type' as dim_a_label,
          'District name' as dim_b_label,
          resource__resource_type as dim_a_value,
          district__district_name as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_day_resource_type_district_name') }}
      where resource__resource_type is not null and district__district_name is not null
  ),

  day_resource_type_district_type as (
      select
          event__metric_time_day__day as date_at_time_grain,
          'day' as time_grain,
          'resource_type_district_type' as dim_set,
          'Resource type' as dim_a_label,
          'District type' as dim_b_label,
          resource__resource_type as dim_a_value,
          district__district_type as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_day_resource_type_district_type') }}
      where resource__resource_type is not null and district__district_type is not null
  ),

  day_resource_type_application_name as (
      select
          event__metric_time_day__day as date_at_time_grain,
          'day' as time_grain,
          'resource_type_application_name' as dim_set,
          'Resource type' as dim_a_label,
          'Application name' as dim_b_label,
          resource__resource_type as dim_a_value,
          event__application_name as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_day_resource_type_application_name') }}
      where resource__resource_type is not null and event__application_name is not null
  ),

  day_district_name_district_type as (
      select
          event__metric_time_day__day as date_at_time_grain,
          'day' as time_grain,
          'district_name_district_type' as dim_set,
          'District name' as dim_a_label,
          'District type' as dim_b_label,
          district__district_name as dim_a_value,
          district__district_type as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_day_district_name_district_type') }}
      where district__district_name is not null and district__district_type is not null
  ),

  day_district_name_application_name as (
      select
          event__metric_time_day__day as date_at_time_grain,
          'day' as time_grain,
          'district_name_application_name' as dim_set,
          'District name' as dim_a_label,
          'Application name' as dim_b_label,
          district__district_name as dim_a_value,
          event__application_name as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_day_district_name_application_name') }}
      where district__district_name is not null and event__application_name is not null
  ),

  day_district_type_application_name as (
      select
          event__metric_time_day__day as date_at_time_grain,
          'day' as time_grain,
          'district_type_application_name' as dim_set,
          'District type' as dim_a_label,
          'Application name' as dim_b_label,
          district__district_type as dim_a_value,
          event__application_name as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_day_district_type_application_name') }}
      where district__district_type is not null and event__application_name is not null
  ),

  -- WEEK GRAIN EXPORTS (16 dimension combinations)

  -- All (no dimensions)
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

  -- Single dimensions
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
      from {{ source('exports', 'qexptbl_week_program_name') }}
      where program__program_name is not null
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
      from {{ source('exports', 'qexptbl_week_resource_type') }}
      where resource__resource_type is not null
  ),

  week_district_name as (
      select
          event__metric_time_week__week as date_at_time_grain,
          'week' as time_grain,
          'district_name' as dim_set,
          'District name' as dim_a_label,
          null as dim_b_label,
          district__district_name as dim_a_value,
          cast(null as varchar) as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_week_district_name') }}
      where district__district_name is not null
  ),

  week_district_type as (
      select
          event__metric_time_week__week as date_at_time_grain,
          'week' as time_grain,
          'district_type' as dim_set,
          'District type' as dim_a_label,
          null as dim_b_label,
          district__district_type as dim_a_value,
          cast(null as varchar) as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_week_district_type') }}
      where district__district_type is not null
  ),

  week_application_name as (
      select
          event__metric_time_week__week as date_at_time_grain,
          'week' as time_grain,
          'application_name' as dim_set,
          'Application name' as dim_a_label,
          null as dim_b_label,
          event__application_name as dim_a_value,
          cast(null as varchar) as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_week_application_name') }}
      where event__application_name is not null
  ),

  -- Two-way combinations
  week_program_name_resource_type as (
      select
          event__metric_time_week__week as date_at_time_grain,
          'week' as time_grain,
          'program_name_resource_type' as dim_set,
          'Program name' as dim_a_label,
          'Resource type' as dim_b_label,
          program__program_name as dim_a_value,
          resource__resource_type as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_week_program_name_resource_type') }}
      where program__program_name is not null and resource__resource_type is not null
  ),

  week_program_name_district_name as (
      select
          event__metric_time_week__week as date_at_time_grain,
          'week' as time_grain,
          'program_name_district_name' as dim_set,
          'Program name' as dim_a_label,
          'District name' as dim_b_label,
          program__program_name as dim_a_value,
          district__district_name as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_week_program_name_district_name') }}
      where program__program_name is not null and district__district_name is not null
  ),

  week_program_name_district_type as (
      select
          event__metric_time_week__week as date_at_time_grain,
          'week' as time_grain,
          'program_name_district_type' as dim_set,
          'Program name' as dim_a_label,
          'District type' as dim_b_label,
          program__program_name as dim_a_value,
          district__district_type as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_week_program_name_district_type') }}
      where program__program_name is not null and district__district_type is not null
  ),

  week_program_name_application_name as (
      select
          event__metric_time_week__week as date_at_time_grain,
          'week' as time_grain,
          'program_name_application_name' as dim_set,
          'Program name' as dim_a_label,
          'Application name' as dim_b_label,
          program__program_name as dim_a_value,
          event__application_name as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_week_program_name_application_name') }}
      where program__program_name is not null and event__application_name is not null
  ),

  week_resource_type_district_name as (
      select
          event__metric_time_week__week as date_at_time_grain,
          'week' as time_grain,
          'resource_type_district_name' as dim_set,
          'Resource type' as dim_a_label,
          'District name' as dim_b_label,
          resource__resource_type as dim_a_value,
          district__district_name as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_week_resource_type_district_name') }}
      where resource__resource_type is not null and district__district_name is not null
  ),

  week_resource_type_district_type as (
      select
          event__metric_time_week__week as date_at_time_grain,
          'week' as time_grain,
          'resource_type_district_type' as dim_set,
          'Resource type' as dim_a_label,
          'District type' as dim_b_label,
          resource__resource_type as dim_a_value,
          district__district_type as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_week_resource_type_district_type') }}
      where resource__resource_type is not null and district__district_type is not null
  ),

  week_resource_type_application_name as (
      select
          event__metric_time_week__week as date_at_time_grain,
          'week' as time_grain,
          'resource_type_application_name' as dim_set,
          'Resource type' as dim_a_label,
          'Application name' as dim_b_label,
          resource__resource_type as dim_a_value,
          event__application_name as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_week_resource_type_application_name') }}
      where resource__resource_type is not null and event__application_name is not null
  ),

  week_district_name_district_type as (
      select
          event__metric_time_week__week as date_at_time_grain,
          'week' as time_grain,
          'district_name_district_type' as dim_set,
          'District name' as dim_a_label,
          'District type' as dim_b_label,
          district__district_name as dim_a_value,
          district__district_type as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_week_district_name_district_type') }}
      where district__district_name is not null and district__district_type is not null
  ),

  week_district_name_application_name as (
      select
          event__metric_time_week__week as date_at_time_grain,
          'week' as time_grain,
          'district_name_application_name' as dim_set,
          'District name' as dim_a_label,
          'Application name' as dim_b_label,
          district__district_name as dim_a_value,
          event__application_name as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_week_district_name_application_name') }}
      where district__district_name is not null and event__application_name is not null
  ),

  week_district_type_application_name as (
      select
          event__metric_time_week__week as date_at_time_grain,
          'week' as time_grain,
          'district_type_application_name' as dim_set,
          'District type' as dim_a_label,
          'Application name' as dim_b_label,
          district__district_type as dim_a_value,
          event__application_name as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_week_district_type_application_name') }}
      where district__district_type is not null and event__application_name is not null
  ),

  -- MONTH GRAIN EXPORTS (16 dimension combinations)

  -- All (no dimensions)
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

  -- Single dimensions
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
      from {{ source('exports', 'qexptbl_month_resource_type') }}
      where resource__resource_type is not null
  ),

  month_district_name as (
      select
          event__metric_time_month__month as date_at_time_grain,
          'month' as time_grain,
          'district_name' as dim_set,
          'District name' as dim_a_label,
          null as dim_b_label,
          district__district_name as dim_a_value,
          cast(null as varchar) as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_month_district_name') }}
      where district__district_name is not null
  ),

  month_district_type as (
      select
          event__metric_time_month__month as date_at_time_grain,
          'month' as time_grain,
          'district_type' as dim_set,
          'District type' as dim_a_label,
          null as dim_b_label,
          district__district_type as dim_a_value,
          cast(null as varchar) as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_month_district_type') }}
      where district__district_type is not null
  ),

  month_application_name as (
      select
          event__metric_time_month__month as date_at_time_grain,
          'month' as time_grain,
          'application_name' as dim_set,
          'Application name' as dim_a_label,
          null as dim_b_label,
          event__application_name as dim_a_value,
          cast(null as varchar) as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_month_application_name') }}
      where event__application_name is not null
  ),

  -- Two-way combinations
  month_program_name_resource_type as (
      select
          event__metric_time_month__month as date_at_time_grain,
          'month' as time_grain,
          'program_name_resource_type' as dim_set,
          'Program name' as dim_a_label,
          'Resource type' as dim_b_label,
          program__program_name as dim_a_value,
          resource__resource_type as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_month_program_name_resource_type') }}
      where program__program_name is not null and resource__resource_type is not null
  ),

  month_program_name_district_name as (
      select
          event__metric_time_month__month as date_at_time_grain,
          'month' as time_grain,
          'program_name_district_name' as dim_set,
          'Program name' as dim_a_label,
          'District name' as dim_b_label,
          program__program_name as dim_a_value,
          district__district_name as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_month_program_name_district_name') }}
      where program__program_name is not null and district__district_name is not null
  ),

  month_program_name_district_type as (
      select
          event__metric_time_month__month as date_at_time_grain,
          'month' as time_grain,
          'program_name_district_type' as dim_set,
          'Program name' as dim_a_label,
          'District type' as dim_b_label,
          program__program_name as dim_a_value,
          district__district_type as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_month_program_name_district_type') }}
      where program__program_name is not null and district__district_type is not null
  ),

  month_program_name_application_name as (
      select
          event__metric_time_month__month as date_at_time_grain,
          'month' as time_grain,
          'program_name_application_name' as dim_set,
          'Program name' as dim_a_label,
          'Application name' as dim_b_label,
          program__program_name as dim_a_value,
          event__application_name as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_month_program_name_application_name') }}
      where program__program_name is not null and event__application_name is not null
  ),

  month_resource_type_district_name as (
      select
          event__metric_time_month__month as date_at_time_grain,
          'month' as time_grain,
          'resource_type_district_name' as dim_set,
          'Resource type' as dim_a_label,
          'District name' as dim_b_label,
          resource__resource_type as dim_a_value,
          district__district_name as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_month_resource_type_district_name') }}
      where resource__resource_type is not null and district__district_name is not null
  ),

  month_resource_type_district_type as (
      select
          event__metric_time_month__month as date_at_time_grain,
          'month' as time_grain,
          'resource_type_district_type' as dim_set,
          'Resource type' as dim_a_label,
          'District type' as dim_b_label,
          resource__resource_type as dim_a_value,
          district__district_type as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_month_resource_type_district_type') }}
      where resource__resource_type is not null and district__district_type is not null
  ),

  month_resource_type_application_name as (
      select
          event__metric_time_month__month as date_at_time_grain,
          'month' as time_grain,
          'resource_type_application_name' as dim_set,
          'Resource type' as dim_a_label,
          'Application name' as dim_b_label,
          resource__resource_type as dim_a_value,
          event__application_name as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_month_resource_type_application_name') }}
      where resource__resource_type is not null and event__application_name is not null
  ),

  month_district_name_district_type as (
      select
          event__metric_time_month__month as date_at_time_grain,
          'month' as time_grain,
          'district_name_district_type' as dim_set,
          'District name' as dim_a_label,
          'District type' as dim_b_label,
          district__district_name as dim_a_value,
          district__district_type as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_month_district_name_district_type') }}
      where district__district_name is not null and district__district_type is not null
  ),

  month_district_name_application_name as (
      select
          event__metric_time_month__month as date_at_time_grain,
          'month' as time_grain,
          'district_name_application_name' as dim_set,
          'District name' as dim_a_label,
          'Application name' as dim_b_label,
          district__district_name as dim_a_value,
          event__application_name as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_month_district_name_application_name') }}
      where district__district_name is not null and event__application_name is not null
  ),

  month_district_type_application_name as (
      select
          event__metric_time_month__month as date_at_time_grain,
          'month' as time_grain,
          'district_type_application_name' as dim_set,
          'District type' as dim_a_label,
          'Application name' as dim_b_label,
          district__district_type as dim_a_value,
          event__application_name as dim_b_value,
          n_active_users,
          n_events
      from {{ source('exports', 'qexptbl_month_district_type_application_name') }}
      where district__district_type is not null and event__application_name is not null
  ),

  final as (
      -- Day grain unions (16 tables)
      select * from day_all
      union all select * from day_program_name
      union all select * from day_resource_type
      union all select * from day_district_name
      union all select * from day_district_type
      union all select * from day_application_name
      union all select * from day_program_name_resource_type
      union all select * from day_program_name_district_name
      union all select * from day_program_name_district_type
      union all select * from day_program_name_application_name
      union all select * from day_resource_type_district_name
      union all select * from day_resource_type_district_type
      union all select * from day_resource_type_application_name
      union all select * from day_district_name_district_type
      union all select * from day_district_name_application_name
      union all select * from day_district_type_application_name

      -- Week grain unions (16 tables)
      union all select * from week_all
      union all select * from week_program_name
      union all select * from week_resource_type
      union all select * from week_district_name
      union all select * from week_district_type
      union all select * from week_application_name
      union all select * from week_program_name_resource_type
      union all select * from week_program_name_district_name
      union all select * from week_program_name_district_type
      union all select * from week_program_name_application_name
      union all select * from week_resource_type_district_name
      union all select * from week_resource_type_district_type
      union all select * from week_resource_type_application_name
      union all select * from week_district_name_district_type
      union all select * from week_district_name_application_name
      union all select * from week_district_type_application_name

      -- Month grain unions (16 tables)
      union all select * from month_all
      union all select * from month_program_name
      union all select * from month_resource_type
      union all select * from month_district_name
      union all select * from month_district_type
      union all select * from month_application_name
      union all select * from month_program_name_resource_type
      union all select * from month_program_name_district_name
      union all select * from month_program_name_district_type
      union all select * from month_program_name_application_name
      union all select * from month_resource_type_district_name
      union all select * from month_resource_type_district_type
      union all select * from month_resource_type_application_name
      union all select * from month_district_name_district_type
      union all select * from month_district_name_application_name
      union all select * from month_district_type_application_name
  )

select *
from final