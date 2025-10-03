with events_dims_daily as(
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
    from    
        {{ ref('rpt_obt_events_dims_daily') }}
),
user_fed as(
    select 
        user_id,
        min(server_event_date) as user_first_event_date
    from 
        events_dims_daily
    group by user_id
),

datespine as (
select
    date_day,
    mau_lookback_start_date,
    wau_lookback_start_date
from 
    {{ ref('dim_day_datespine') }}
),

final as (
    select
        datespine.date_day,
        datespine.mau_lookback_start_date,
        datespine.wau_lookback_start_date,
        datespine.date_day = user_fed.user_first_event_date as is_user_first_event_date,
        datespine.mau_lookback_start_date >= user_fed.user_first_event_date as is_user_eligible_for_mau,
        events_dims_daily.*
    from datespine
    left join events_dims_daily
        on events_dims_daily.server_event_date between datespine.mau_lookback_start_date
           and datespine.date_day
    left join user_fed
        on events_dims_daily.user_id = user_fed.user_id
)
select *
from 
    final
where user_id = 499751 order by date_day, server_event_date
