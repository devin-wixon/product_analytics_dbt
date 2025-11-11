with events as (
    select *
    from
        {{ ref('fct_events') }}
),

user_district_role_date as (
    select
        server_event_date,
        user_id,
        district_id,
        user_role,
        user_invite_status,
        match_type
    from
        {{ ref('int_users_district_role_date') }}
),

event_user_joined as (
    select
        events.*,
        user_district_role_date.district_id,
        user_district_role_date.user_role,
        user_district_role_date.user_invite_status,
        user_district_role_date.match_type
    from events
    left join user_district_role_date on
        events.user_id = user_district_role_date.user_id
        and events.server_event_date = user_district_role_date.server_event_date
),

user_daily_activity as (
    select
        {{ dbt_utils.generate_surrogate_key([
            'user_id',
            'server_event_date',
            "coalesce(user_role, 'none')",
            'coalesce(district_id, -1)',
            'coalesce(program_id, -1)',
            'coalesce(resource_id, -1)',
            "coalesce(application_name, 'none')",
            "coalesce(event_category, 'none')"
        ]) }} as user_daily_context_sk,

        count(event_id) as n_events_per_user_day_context,
        True as had_events_per_user_day_context,

        -- If event categories are pivoted to boolean data create activity flags for all event types
        -- {#
        -- {%- if event_categories %}
        --     {%- for category in event_categories %}
        -- max(is_{{ category }}_event) as had_{{ category }}_activity_per_user_day_context,
        --     {%- endfor %}
        -- {%- endif %}
        -- #}

        -- Include key dimensional context columns
        user_id,
        server_event_date,
        district_id,
        program_id,
        resource_id,
        application_name,
        event_category,
        user_role,
        user_invite_status,
        match_type
    from
        event_user_joined
    group by all
),

final as (
    select *
    from
        user_daily_activity
)

select *
from
    final
