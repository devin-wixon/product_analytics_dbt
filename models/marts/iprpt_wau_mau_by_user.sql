{{ 
  config(
    enabled = false,
    materialized = 'incremental', 
    incremental_strategy = 'merge',
    unique_key = [
        'date_day',
        'server_event_date',
        'user_id',
        'user_role',
        'event_category',
        'program_id',
        'resource_id',
        'district_id',
        'application_name'
    ],
    on_schema_change = "sync_all_columns"
  ) 
}}


with events_dims_daily as (
    select
        server_event_date,
        school_year_label,
        school_year_start_date,
        user_id,
        user_role,
        event_category,
        program_id,
        program_name,
        resource_id,
        resource_title,
        resource_type,
        district_id,
        district_name,
        district_type,
        district_state,
        is_distributed_demo_district,
        application_name
    from {{ ref('rpt_obt_events_dims_daily') }}
),

user_fed as (
    select
        user_id,
        min(server_event_date) as user_first_event_date
    from events_dims_daily
    group by user_id
),

datespine as (
    select
        date_day,
        mau_lookback_start_date,
        wau_lookback_start_date
    from {{ ref('dim_day_datespine') }}
),

final as (
    select
        datespine.date_day,
        datespine.mau_lookback_start_date,
        datespine.wau_lookback_start_date,
        datespine.date_day = user_fed.user_first_event_date
            as is_user_first_event_date,
        datespine.mau_lookback_start_date >= user_fed.user_first_event_date
            as is_user_eligible_for_mau,
        events_dims_daily.server_event_date,
        events_dims_daily.school_year_label,
        events_dims_daily.school_year_start_date,
        events_dims_daily.user_id,
        events_dims_daily.user_role,
        events_dims_daily.event_category,
        events_dims_daily.program_id,
        events_dims_daily.program_name,
        events_dims_daily.resource_id,
        events_dims_daily.resource_title,
        events_dims_daily.resource_type,
        events_dims_daily.district_id,
        events_dims_daily.district_name,
        events_dims_daily.district_type,
        events_dims_daily.district_state,
        events_dims_daily.is_distributed_demo_district,
        events_dims_daily.application_name
    from datespine
    left join events_dims_daily
        on events_dims_daily.server_event_date
            between datespine.mau_lookback_start_date
            and datespine.date_day
    left join user_fed
        on events_dims_daily.user_id = user_fed.user_id
)

select *
from final
