{% macro assign_event_type(event_category_column) %}

    {#-
        Assigns each `event_category` value a higher-level event type based on a hardcoded mapping for reporting.

        ARGUMENTS:
        - event_category_column: The event_category column to map (can be a column reference or literal value)

        BEHAVIOR:
        Returns a case statement that maps event_category values to their corresponding event_type.
        Returns NULL for event categories that don't have a defined event type.

        USAGE:
        select
            event_category,
            {%raw%}{{ assign_event_type('event_category') }}{%endraw%} as event_type
        from your_table
    -#}

    decode(
        {{ event_category_column }},
        'error', 'Error',
        'interface', 'General interface',
        'join_feedback_community', 'Join feedback community',
        'app_launch', 'Launch app',
        'login', 'Login or out',
        'logout', 'Login or out',
        'music_action', 'Music action',
        'page_navigation', 'Navigation',
        'planner_card_open', 'Planner cards',
        'planner_card_status', 'Planner cards',
        'planner_change_framework', 'Planner filter',
        'planner_filter', 'Planner filter',
        'planner_launch', 'Planner launch',
        'planner_modal', 'Planner modal',
        'planner_print', 'Planner report or print',
        'planner_report', 'Planner report or print',
        'planner_report_skills', 'Planner report or print',
        'planner_week_complete', 'Planner report or print',
        'pop_up_click', 'Pop up',
        'pop_up_dismiss', 'Pop up',
        'pop_up_view', 'Pop up',
        'resource_download', 'Print or download',
        'resource_print', 'Print or download',
        'resource_open_header_frameworks', 'Resource frameworks header',
        'resource_more_sidebar', 'Resource more sidebar',
        'resource_pdf_ui', 'Resource pdf action',
        'resources_accordion', 'Resources accordion',
        'resource_search', 'Resources search',
        'resources_sidebar_filter', 'Resources sidebar filter',
        'support_request', 'Support request',
        'video_action', 'Video action',
        null
    )

{% endmacro %}
