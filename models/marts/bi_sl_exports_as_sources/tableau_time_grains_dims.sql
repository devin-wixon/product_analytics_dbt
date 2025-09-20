  with

  month_program as (
      select
          event__metric_time_month__month as month,
          'month' as time_grain,
          'program' as dim_set,
          program__program_name as program_name,
          cast(null as varchar) as resource_type_name,
          n_active_users,
          n_events
      from
          {{ source('exports', 'qexptbl_month_program') }}
  ),

  month_resource_type as (
      select
          event__metric_time_month__month as month,
          'month' as time_grain,
          'resource_type' as dim_set,
          cast(null as varchar) as program_name,
          resource__resource_type as resource_type_name,
          n_active_users,
          n_events
      from
          {{ source('exports', 'qexptbl_month_resource_type') }}
  ),

  month_program_resource_type as (
      select
          event__metric_time_month__month as month,
          'month' as time_grain,
          'program__resource_type' as dim_set,
          program__program_name as program_name,
          resource__resource_type as resource_type_name,
          n_active_users,
          n_events
      from
          {{ source('exports', 'qexptbl_month_program_resource_type') }}
  ),

  final as (
      select * from month_program
      union all
      select * from month_resource_type
      union all
      select * from month_program_resource_type
  )

  select *
  from
      final