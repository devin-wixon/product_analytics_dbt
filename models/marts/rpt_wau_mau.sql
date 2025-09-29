{% set dimensions = [
    'district_id',
    'program_id',
    'resource_id',
    'application_name',
    'resource_type',
    'event_category'
] %}

with calendar_dates as (
    select
        date_day
    from {{ ref('dim_day_datespine') }}
    where date_day <= convert_timezone('utc', current_timestamp())::date
),

events as (
    select
        server_event_date,
        user_id,
        district_id,
        program_id,
        resource_id,
        application_name,
        resource_type,
        event_category,
        sum(n_events_per_user_day_context) as n_events_per_user_day_context,
        min(example_event_id) as example_event_id
    from {{ ref('rpt_obt_events_dims_daily') }}
    group by all
),

-- build user–dimension pairs for densification
user_dimension_pairs as (
    select distinct
        user_id
        {% for dim in dimensions %}, {{ dim }}{% endfor %}
    from events
),

-- densify: every user–dimension pair × every calendar date
user_dimension_dates as (
    select
        calendar_dates.date_day,
        user_dimension_pairs.user_id
        {% for dim in dimensions %}, user_dimension_pairs.{{ dim }}{% endfor %}
    from user_dimension_pairs
    cross join calendar_dates
),

-- dimension-scoped first events
{% for dim in dimensions -%}
user_first_event_{{ dim }} as (
    select
        user_id,
        {{ dim }},
        min(server_event_date) as user_first_event_{{ dim }}
    from events
    group by user_id, {{ dim }}
){% if not loop.last %},{% endif %}
{% endfor %},

base as (
    select
        user_dimension_dates.date_day,
        user_dimension_dates.user_id
        {% for dim in dimensions %}, user_dimension_dates.{{ dim }}{% endfor %},

        coalesce(events.n_events_per_user_day_context, 0) as n_events_per_user_day_context,
        events.example_event_id

        {% for dim in dimensions %}
        , user_first_event_{{ dim }}.user_first_event_{{ dim }}
        , case
            when user_dimension_dates.date_day >= dateadd(day, 28, user_first_event_{{ dim }}.user_first_event_{{ dim }})
            then true else false
          end as is_user_first_date_over_28_days_{{ dim }}
        {% endfor %}

    from user_dimension_dates

    left join events
      on user_dimension_dates.user_id = events.user_id
     and user_dimension_dates.date_day = events.server_event_date
     {% for dim in dimensions %}
     and user_dimension_dates.{{ dim }} = events.{{ dim }}
     {% endfor %}

    {% for dim in dimensions %}
    left join user_first_event_{{ dim }}
      on user_dimension_dates.user_id = user_first_event_{{ dim }}.user_id
     and user_dimension_dates.{{ dim }} = user_first_event_{{ dim }}.{{ dim }}
    {% endfor %}
),

rolled as (
    select
        base.date_day,
        base.user_id
        {% for dim in dimensions %}, base.{{ dim }}{% endfor %},

        base.n_events_per_user_day_context,
        base.example_event_id

        {% for dim in dimensions %}
        , base.user_first_event_{{ dim }}
        , base.is_user_first_date_over_28_days_{{ dim }}

        , max(case when base.n_events_per_user_day_context > 0 then 1 end) over (
            partition by base.user_id, base.{{ dim }}
            order by base.date_day
            rows between 6 preceding and current row
          ) as is_active_last_7d_{{ dim }}

        , max(case when base.n_events_per_user_day_context > 0 then 1 end) over (
            partition by base.user_id, base.{{ dim }}
            order by base.date_day
            rows between 27 preceding and current row
          ) as is_active_last_28d_{{ dim }}
        {% endfor %}

    from base
)

select *
from rolled
