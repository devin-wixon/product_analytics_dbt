with

calendar_dates as (

    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2025-02-01' as date)",
        end_date="cast('2050-12-31' as date)"
    )
    }}

),

final as (

    select
        -- date_day will serve as the natural key
        date_day::date as date_day,
        date_trunc('week', date_day) as week_monday_date,
        date_trunc('month', date_day) as month_start_date,

        dayofweek(date_day) as day_of_week_number,
        dayofmonth(date_day) as day_of_month_number,
        dayofyear(date_day) as day_of_year_number,
        week(date_day) as week_of_year_number,
        month(date_day) as month_of_year_number,
        quarter(date_day) as quarter_of_year_number,
        year(date_day) as year_number,

        dayname(date_day) as short_weekday_name,        
        case dayofweek(date_day)
            when 0 then 'Sunday'
            when 1 then 'Monday'
            when 2 then 'Tuesday'
            when 3 then 'Wednesday'
            when 4 then 'Thursday'
            when 5 then 'Friday'
            when 6 then 'Saturday'
        end as full_weekday_name,
        
        monthname(date_day) as short_month_name,
        to_char(date_day,'MMMM') as full_month_name,
        to_char(date_day, 'YY-MM') as year_month_sort,
        to_char(date_day, 'YY') || '-' || quarter(date_day) as year_quarter_sort,
        concat(monthname(date_day), ' ', year(date_day)) as short_month_year,
        -- concat(to_char(date_day,'MMMM'), ' ', year(date_day)) as full_month_year,

        -- wau mau rolling dates; also need to add conidition that user start <= 28 days
        dateadd(day, -6, date_day) as wau_lookback_start_date,
        dateadd(day, -27, date_day) as mau_lookback_start_date,

        -- School year calculations (July 1 - June 30)
        -- Not using a macro; do once here for joining everywhere
        case
            when month(date_day) >= {{ var('school_year_start_month') }}
            then concat(
                     right((year(date_day))::string, 2), '-', right((year(date_day) + 1)::string, 2)
                    )
            else concat(
                 right((year(date_day) - 1)::string, 2), '-', right(year(date_day)::string, 2)
                )
        end as school_year_label,

        -- school_year_start_date: Use the project-level var combined with the last two of the school year label
        concat(
                '20' || left(school_year_label, 2), '-',
                {{ var('school_year_start_month') }}::string, '-',
                {{ var('school_year_start_day') }}::string
              )::date as school_year_start_date

    from calendar_dates

)

select * from final
