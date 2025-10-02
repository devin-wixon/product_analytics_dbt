{config(
    enabled=False
)}

{% set dimensions = [
    'application_name',
    'district_id',
    'program_id',
    'resource_id',
    'resource_type',
    'event_category'
] %}

with calendar_dates as (
    select
        date_day
    from {{ ref('dim_day_datespine') }}
    where date_day <= convert_timezone('UTC', current_timestamp())::date
),

events as (
    select
        server_event_date,
        user_id,
        district_id,
        district_name,
        district_type,
        program_id,
        resource_id,
        application_name,
        resource_type,
        event_category
    from {{ ref('rpt_obt_events_dims_daily') }}
),

-- build user–district pairs for densification
user_district_pairs as (
    select distinct
        user_id,
        district_id
    from events
),

-- densify user–district × dates
user_district_dates as (
    select
        calendar_dates.date_day,
        user_district_pairs.user_id,
        user_district_pairs.district_id
    from user_district_pairs
    cross join calendar_dates
),

-- dimension-scoped blocks
{% for dim in dimensions %}
-- districts are used in filter; district is also a potential aggregation
-- so district_id will be repeated for one block
{{ dim }}_base as (
    select distinct
        udd.date_day,
        udd.user_id,
        udd.district_id,
        cast(events.{{ dim }} as varchar) as dim_value,
        '{{ dim }}' as dim_name,
        case
            when udd.date_day >= dateadd(
                day,
                28,
                first_event.first_event_date_user_dim
            )
                then true
            else false
        end as is_user_dim_eligible,
        events.user_id as had_event_user
    from user_district_dates udd
    left join events
      on udd.user_id = events.user_id
     and udd.date_day = events.server_event_date
    left join (
        select
            user_id,
            {{ dim }},
            min(server_event_date) as first_event_date_user_dim
        from events
        group by user_id, {{ dim }}
    ) as first_event
      on udd.user_id = first_event.user_id
     and events.{{ dim }} = first_event.{{ dim }}
),

{{ dim }}_rolled as (
    with windowed as (
        select
            {{ dim }}_base.date_day,
            {{ dim }}_base.user_id,
            {{ dim }}_base.district_id,
            {{ dim }}_base.dim_value,
            {{ dim }}_base.dim_name,
            {{ dim }}_base.is_user_dim_eligible,
            max(
                case
                    when {{ dim }}_base.had_event_user is not null
                        then 1
                    else 0
                end
            ) over (
                partition by
                    {{ dim }}_base.user_id,
                    {{ dim }}_base.dim_value
                order by {{ dim }}_base.date_day
                rows between 6 preceding and current row
            ) as has_wau_window,
            max(
                case
                    when {{ dim }}_base.had_event_user is not null
                        then 1
                    else 0
                end
            ) over (
                partition by
                    {{ dim }}_base.user_id,
                    {{ dim }}_base.dim_value
                order by {{ dim }}_base.date_day
                rows between 27 preceding and current row
            ) as has_mau_window
        from {{ dim }}_base
    )
    select
        date_day,
        district_id,
        dim_value,
        dim_name,
        count(
            distinct case
                when is_user_dim_eligible and has_wau_window = 1
                    then user_id
            end
        ) as wau,
        count(
            distinct case
                when is_user_dim_eligible and has_mau_window = 1
                    then user_id
            end
        ) as mau
    from windowed
    group by
        date_day,
        district_id,
        dim_value,
        dim_name
)
{% if not loop.last %},{% endif %}
{% endfor %}

, final as (
    {% for dim in dimensions %}
    select * from {{ dim }}_rolled
    {% if not loop.last %}union all{% endif %}
    {% endfor %}
),

final_with_names as (
    select
        final.*,
        div0(wau, mau) as wau_mau_ratio,
        districts_lookup.district_name,
        districts_lookup.district_type
    from final
    left join (
        select distinct
            district_id,
            district_name,
            district_type
        from events
    ) as districts_lookup
        on final.district_id = districts_lookup.district_id
)

select *
from final_with_names
