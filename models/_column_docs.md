

{% docs event_value_integer_join_column %}
Indicates which type of entity (e.g., program_id, resource_id) the event_value should join to, based on event_name and only if event_value is numeric. Used to determine how to join event_value to other tables.
{% enddocs %}


{% docs launched_application_name %}
The application name (string) launched by the user, populated only for events where event_name = 'productLaunchOpen'.
{% enddocs %}


{% docs path_entered %}
For 'router.left' events, the route/path the user navigated to (event_path value).
{% enddocs %}


{% docs path_left %}
For 'router.left' events, the route/path the user navigated away from (event_value value).
{% enddocs %}


{% docs program_id %}
Integer program_id derived from event_value or event_path, only for events where event_value is a numeric program_id or can be parsed from the path. Null if not applicable.
{% enddocs %}


{% docs resource_id %}
Integer resource_id derived from event_value or event_path, only for events where event_value is a numeric resource_id or can be parsed from the path. Null if not applicable.
{% enddocs %}


{% docs is_login_event %}
Boolean: True if event_name is 'auth.login', otherwise false.
{% enddocs %}


{% docs is_planner_open_event %}
Boolean: True if event_name is 'weekly.planner.modal.program.week.select' or 'weekly.planner.modal.lastWeeklyPlanner.open', otherwise false.
{% enddocs %}


{% docs is_weekly_planner_event %}
Boolean: True if event_name starts with 'weekly.planner' but does not start with 'weekly.planner.modal', otherwise false.
{% enddocs %}
