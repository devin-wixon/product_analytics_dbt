
-- TAG TO DO: Configure this to build as incremental table by client_event_date; expensive to run and build

with events as (
    select *
    from 
        {{ ref('fct_events') }}
),

user_district_role as
(select
    user_id,
    district_id,
    user_role,
    user_email_sent_utc
from
    {{ ref('int_users_district_role') }}
),

-- if event categories are pivoted to boolean data
    -- {#
    -- {%- set event_categories = dbt_utils.get_column_values(
    --     table=ref('seed_event_log_metadata'),
    --     column='event_category',
    --     where="event_category is not null and event_category != ''",
    --     order_by='event_category'
    --     )%}
    -- #}

event_user_joined as
(select 
    events.*,
    user_district_role.district_id,
    user_district_role.user_role,
    user_district_role.user_email_sent_utc
from 
    events
left join
    user_district_role
on
    events.user_id = user_district_role.user_id
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
        event_category
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