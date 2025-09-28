{% docs authentication_classlink_settings_classlink_id %}
ClassLink organization identifier for authentication.
{% enddocs %}


{% docs authentication_clever_settings_clever_id %}
Clever district identifier for authentication.
{% enddocs %}


{% docs authentication_clever_settings_provider_name %}
Human-readable name of the Clever provider/district.
{% enddocs %}


{% docs authentication_provider %}
Primary authentication provider for the district.
{% enddocs %}


{% docs authentication_saml_settings_metadata_document_source %}
Source type for SAML metadata document (e.g., file).
{% enddocs %}


{% docs authentication_saml_settings_provider_name %}
Name identifier for the SAML provider.
{% enddocs %}


{% docs district_grades %}
Comma-separated list of grade levels supported by the district.
{% enddocs %}


{% docs client_event_date %}
Date of the event, derived from client timestamp.
{% enddocs %}


{% docs server_event_date %}
Date of the event, derived from server timestamp.
{% enddocs %}


{% docs is_onboarding_required %}
True means admins (with permission) will be redirected to onboarding as soon they login while other users will be redirected to an error page
{% enddocs %}


{% docs rostering_method %}
Values: classlink, clever, flat_file_csv, oneroster
{% enddocs %}


{% docs rostering_rostering_type %}
Values: replace, additive
{% enddocs %}


{% docs rostering_state_id_field %}
<!-- TAG TO DO confirm values and flesh out with their meaning. -->
Values: stateid, identifier, username, sourcedid, state
{% enddocs %}

{% docs rostering_upload_method %}
Values: manual, sftp.
{% enddocs %}

{% docs is_selfservice_authentication_show_clever %}
Controls visibility of Clever authentication in self-service portal.
{% enddocs %}

{% docs is_selfservice_rostering_show_clever %}
Controls visibility of Clever rostering in self-service portal.
{% enddocs %}


{% docs user_pool_client_id %}
AWS Cognito User Pool client identifier for authentication services.
{% enddocs %}


{% docs event_category %}
Manually hardcoded category associated with an `event_name` in the event metadata seed.
{% enddocs %}


{% docs event_value_integer_join_column %}
Indicates which type of entity (e.g., program_id, resource_id) the event_value should join to, based on event_name and only if event_value is numeric. Used to determine how to join event_value to other tables.
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


{% docs is_app_launch_event %}
Boolean: True if event_name is 'productLaunchOpen', otherwise false.
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


{% docs day_of_week_number %}
Day of week as integer using Snowflakes dayofweek() function, which returns:  
SUNDAY=0, MONDAY=1, TUESDAY=2, WEDNESDAY=3, THURSDAY=4, FRIDAY=5, SATURDAY=6
{% enddocs %}


{% docs is_distributed_demo_district %}
Boolean indicating whether the district is one of the distributed demo districts given to organizations for Back to School onboarding.
{% enddocs %}


{% docs week_number %}
Week number extracted from planner event paths for weekly planner events.
{% enddocs %}


{% docs date_day %}
The calendar date serving as the natural key for the date dimension.
{% enddocs %}


{% docs week_monday_date %}
Date of the Monday for the week containing the calendar date, calculated using date_trunc('week', date_day).
{% enddocs %}


{% docs month_start_date %}
First date of the month containing the calendar date, calculated using date_trunc('month', date_day).
{% enddocs %}


{% docs day_of_month_number %}
Day of the month as an integer (1-31), extracted using dayofmonth() function.
{% enddocs %}


{% docs day_of_year_number %}
Day of the year as an integer (1-366), extracted using dayofyear() function.
{% enddocs %}


{% docs week_of_year_number %}
Week number of the year as an integer, extracted using week() function.
{% enddocs %}


{% docs month_of_year_number %}
Month number of the year as an integer (1-12), extracted using month() function.
{% enddocs %}


{% docs quarter_of_year_number %}
Quarter number of the year as an integer (1-4), extracted using quarter() function.
{% enddocs %}


{% docs year_number %}
Four-digit year number as an integer, extracted using year() function.
{% enddocs %}


{% docs short_weekday_name %}
Abbreviated weekday name (e.g., Mon, Tue, Wed), extracted using dayname() function.
{% enddocs %}


{% docs full_weekday_name %}
Full weekday name (e.g., Monday, Tuesday, Wednesday), derived from day of week number using case statement.
{% enddocs %}


{% docs short_month_name %}
Abbreviated month name (e.g., Jan, Feb, Mar), extracted using monthname() function.
{% enddocs %}


{% docs full_month_name %}
Full month name (e.g., January, February, March), extracted using to_char(date_day,'MMMM') function.
{% enddocs %}


{% docs year_month_sort %}
Year and month in YY-MM format for chronological sorting (e.g., 25-01, 25-12, 26-01), formatted using to_char() function.
{% enddocs %}


{% docs year_quarter_sort %}
Year and quarter in YY-Q format for chronological sorting (e.g., 25-1, 25-4, 26-1), combining year and quarter values.
{% enddocs %}


{% docs short_month_year %}
Abbreviated month and year display (e.g., Jan 2025), concatenating month name and year.
{% enddocs %}


{% docs school_year_label %}
School year as a two-digit label (e.g., "24-25") based on July 1 - June 30 academic calendar, where the school year starts in July.
{% enddocs %}


{% docs school_year_start_date %}
Start date of the school year (e.g., 2025-07-01), calculated from school year label and project variables for start month/day.
{% enddocs %}