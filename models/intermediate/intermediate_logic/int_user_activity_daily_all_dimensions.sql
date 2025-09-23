with events as (
    select *
    from {{ ref('fct_events') }}
    where user_id is not null
        and client_event_date is not null
),

-- Get all boolean event columns dynamically
{% set boolean_event_columns = [] %}
{% set results = run_query("select * from " ~ ref('fct_events') ~ " limit 0") %}
{% if execute %}
    {% for column in results.columns %}
        {% if column.name.startswith('is_') and column.name.endswith('_event') %}
            {% do boolean_event_columns.append(column.name) %}
        {% endif %}
    {% endfor %}
{% endif %}

user_daily_activity as (
    select
        -- Explicit primary key
        {{ dbt_utils.generate_surrogate_key([
            'user_id',
            'client_event_date',
            'coalesce(district_id, -1)',
            'coalesce(program_id, -1)',
            'coalesce(resource_id, -1)',
            "coalesce(application_name, 'none')"
        ]) }} as user_daily_context_pk,

        count(event_id) as n_events_per_user_day,
        1 as had_events_per_user_day,

        -- Dynamically create activity flags for all event types
        {% for col in boolean_event_columns %}
        max({{ col }}) as had_{{ col.replace('is_', '').replace('_event', '') }}_activity_per_user_day,
        {% endfor %}

        -- Include key dimensional columns explicitly to avoid exclusion issues
        user_id,
        client_event_date,
        district_id,
        program_id,
        resource_id,
        application_name
    from events
    group by all
),

final as (
    select *
    from user_daily_activity
)

select * from final