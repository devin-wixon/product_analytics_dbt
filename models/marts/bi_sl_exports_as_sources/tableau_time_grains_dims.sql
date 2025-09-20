  with

  month_program as (
      select
          event__metric_time_month__month as date_spine,
          'month' as time_grain,
          'program' as dim_set,
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
          event__metric_time_month__month as date_spine,
          'month' as time_grain,
          'resource_type' as dim_set,
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
          event__metric_time_month__month as date_spine,
          'month' as time_grain,
          'program__resource_type' as dim_set,
          program__program_name as dim_a_value,
          resource__resource_type as dim_b_value,
          n_active_users,
          n_events
      from
          {{ source('exports', 'qexptbl_month_program_resource_type') }}
    where
         -- they can't both be null
        program__program_name is not null or resource__resource_type is not null
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