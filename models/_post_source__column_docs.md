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


{% docs client_event_date %}
Date of the event, derived from client timestamp.
{% enddocs %}


{% docs date_day %}
The calendar date serving as the natural key for the date dimension.
{% enddocs %}


{% docs day_of_month_number %}
Day of the month as an integer (1-31), extracted using dayofmonth() function.
{% enddocs %}


{% docs day_of_week_number %}
Day of week as integer using Snowflake's dayofweek() function, which returns:
SUNDAY=0, MONDAY=1, TUESDAY=2, WEDNESDAY=3, THURSDAY=4, FRIDAY=5, SATURDAY=6
{% enddocs %}


{% docs day_of_year_number %}
Day of the year as an integer (1-366), extracted using dayofyear() function.
{% enddocs %}


{% docs days_elapsed_first_to_second_active_day %}
Number of days between first and second active day. Null if user has not been active on 2+ days.
{% enddocs %}


{% docs district_grades %}
Comma-separated list of grade levels supported by the district.
{% enddocs %}


{% docs event_category %}
Manually hardcoded category associated with an `event_name` in the event metadata seed.
{% enddocs %}


{% docs event_value_integer_join_column %}
Indicates which type of entity (e.g., program_id, resource_id) the event_value should join to, based on event_name and only if event_value is numeric. Used to determine how to join event_value to other tables.
{% enddocs %}


{% docs example_event_id %}
An event id chosen arbitrarily to allow traceability when changing the granularity above the event level.
{% enddocs %}


{% docs full_month_name %}
Full month name (e.g., January, February, March), extracted using to_char(date_day,'MMMM') function.
{% enddocs %}


{% docs full_weekday_name %}
Full weekday name (e.g., Monday, Tuesday, Wednesday), derived from day of week number using case statement.
{% enddocs %}


{% docs is_app_launch_event %}
Boolean: True if event_name is 'productLaunchOpen', otherwise false.
{% enddocs %}


{% docs is_distributed_demo_district %}
Boolean: True if the district is one of the distributed demo districts given to organizations for Back to School onboarding, otherwise false.
{% enddocs %}


{% docs is_login_event %}
Boolean: True if event_name is 'auth.login', otherwise false.
{% enddocs %}


{% docs is_onboarding_required %}
True means admins (with permission) will be redirected to onboarding as soon they login while other users will be redirected to an error page
{% enddocs %}


{% docs is_planner_event %}
Boolean: True if the `event_category` starts with `planner`, but isn't the planner modal.
Needed to assess the broad launch and use of any functionality within the weekly planner; the modal is used only to launch it.,
{% enddocs %}


{% docs is_program_deleted %}
Boolean: True if either dbt snapshots identifies a row as no longer in the source data _or_ the program has a deleted date.
Note that deleted programs are typically retained in Craft, with a deleted date added.
{% enddocs %}


{% docs is_resource_deleted %}
Boolean: True if either dbt snapshots identifies a row as no longer in the source data _or_ the resource has a deleted date.
Note that deleted resources were historically not retained in Craft, and as of Nov 2025 began to be retained with a deleted date column.
{% enddocs %}


{% docs is_rostering_allow_users_without_class_or_school %}
True if invalid users for the district, such as students and teachers without a class, are allowed functionality. See `user_role` for more information.
{% enddocs %}


{% docs is_selfservice_authentication_show_clever %}
Controls visibility of Clever authentication in self-service portal.
{% enddocs %}


{% docs is_selfservice_rostering_show_clever %}
Controls visibility of Clever rostering in self-service portal.
{% enddocs %}


{% docs is_user_active %}
Boolean: True if user had at least one event on any day, otherwise false. Applies to all user categories in the funnel calculations.
{% enddocs %}


{% docs is_user_active_two_days %}
Boolean: True if user had events on 2 or more distinct days, otherwise false. Applies to all user categories in the funnel calculations.
{% enddocs %}


{% docs is_user_created %}
Boolean: True for all users; retained for funnel calculations.
{% enddocs %}

{% docs is_user_eligible_for_mau %}
At the row's date value, is the user's first event date before 27 days prior (the `mau_lookback_start_date`)?
Used to determine if a user should be in the WAU/MAU ratio and excluding users that didn't have the full MAU opportunity space.
{% enddocs %}


{% docs is_user_first_event_date %}
Boolean: True if the current date matches the user's first event date across all events captured, otherwise false.
{% enddocs %}


{% docs is_user_invited %}
Boolean: True if user is a username password type in their most recent user record and had `user_invite_status` =  'invited' _or_ has events at any time, otherwise false or null.
Null for legacy/sso/backfill users (invitation phase does not apply).
{% enddocs %}


{% docs is_user_not_invited %}
Boolean: True if user is a username password type in their most recent user record and had `user_invite_status` = 'not_invited' at any time, otherwise false or null.
Null for legacy/sso/backfill users (not_invited phase does not apply).
{% enddocs %}


{% docs is_user_registered %}
Boolean: True if user is a username password type in their most recent user record and had `user_invite_status` = 'registered' _or_ has events at any time, otherwise false or null.
Null for legacy/sso/backfill users (registration phase does not apply).
{% enddocs %}


{% docs is_weekly_planner_event %}
Boolean: True if event_name starts with 'weekly.planner' but does not start with 'weekly.planner.modal', otherwise false.
{% enddocs %}


{% docs mau_lookback_start_date %}
The date 27 days prior to the date day in the date scaffolding model. Used for scaffolding 28 day rolling calculations.
{% enddocs %}


{% docs min_user_active_date %}
Earliest date the user has a captured event, based on the server timestamp.  
Null if user has never had any events.
{% enddocs %}


{% docs min_user_invited_date %}
Earliest `dbt_valid_from` date when `user_invite_status` was 'invited'.  
Null for users with `user_category` legacy/sso/backfill, or username_password users who were inferred (have events but no 'invited' record).
{% enddocs %}


{% docs min_user_not_invited_date %}
Earliest `dbt_valid_from` date when `user_invite_status` was 'not_invited'.
Null for users with `user_category` in legacy/sso/backfill, or username_password users who never had not_invited status.
{% enddocs %}


{% docs min_user_register_date %}
Earliest `dbt_valid_from` date when `user_invite_status` was 'registered'.
Null for users with `user_category` in legacy/sso/backfill, or username_password users who were inferred (have events but no 'registered' record).
{% enddocs %}


{% docs month_of_year_number %}
Month number of the year as an integer (1-12), extracted using month() function.
{% enddocs %}


{% docs month_start_date %}
First date of the month containing the calendar date, calculated using date_trunc('month', date_day).
{% enddocs %}


{% docs n_user_active_days %}
Total count of distinct days the user had events, based in the server timestamp.  Zero if user has never had any events.
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


{% docs program_event_category_id %}
Unique identifier for models that aggregate by program id and event category.
{% enddocs %}


{% docs program_resource_type_id %}
Unique identifier for models that aggregate by program id and resource type.
{% enddocs %}


{% docs quarter_of_year_number %}
Quarter number of the year as an integer (1-4), extracted using quarter() function.
{% enddocs %}


{% docs resource_id %}
Integer resource_id derived from event_value or event_path, only for events where event_value is a numeric resource_id or can be parsed from the path. Null if not applicable.
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


{% docs school_year_label %}
School year as a two-digit label (e.g., "24-25") based on July 1 - June 30 academic calendar, where the school year starts in July.
{% enddocs %}


{% docs school_year_start_date %}
Start date of the school year (e.g., 2025-07-01), calculated from school year label and project variables for start month/day.
{% enddocs %}


{% docs second_user_active_date %}
Second active day the user had events, based on the server timestamp. Null if user has been active on less than 2 days.
{% enddocs %}


{% docs server_event_date %}
Date of the event, derived from server timestamp.
{% enddocs %}


{% docs short_month_name %}
Abbreviated month name (e.g., Jan, Feb, Mar), extracted using monthname() function.
{% enddocs %}


{% docs short_month_year %}
Abbreviated month and year display (e.g., Jan 2025), concatenating month name and year.
{% enddocs %}


{% docs short_weekday_name %}
Abbreviated weekday name (e.g., Mon, Tue, Wed), extracted using dayname() function.
{% enddocs %}


{% docs user_category %}
User category for funnel calculations based on most recent `dbt_valid_from` and `user_invite_status`.

| value | meaning |
|-------|---------|
| backfill | Users whose most recent `user_invite_status` is 'backfill' (manually backfilled users; will have `dbt_valid_from` = '1900-01-01'; may not have a record with null `dbt_valid_to`) |
| legacy | Non-backfill users with `dbt_valid_from` = '1900-01-01' (unknown entry date) |
| sso | Users whose most recent `user_invite_status` is 'sso' (and not backfill/legacy) |
| username_password | All other users (not backfill, not legacy, not sso) |
{% enddocs %}


{% docs user_current_invite_status %}
The most recent `user_invite_status` value for the user.
{% enddocs %}


{% docs user_first_event_date %}
The first event date for the user at any time, ignoring any filters and context such as dimensions.
{% enddocs %}


{% docs user_role_match_type %}
Indicates whether the user record was matched via 'exact' SCD logic or 'fallback' temporal proximity. Used for data quality monitoring.
{% enddocs %}


{% docs user_pool_client_id %}
AWS Cognito User Pool client identifier for authentication services.
{% enddocs %}


{% docs wau_lookback_start_date %}
The date six days prior to the date day in the date scaffolding model. Used for scaffolding 7 day rolling calculations.
{% enddocs %}


{% docs week_monday_date %}
Date of the Monday for the week containing the calendar date, calculated using date_trunc('week', `date_day`).
{% enddocs %}


{% docs week_number %}
Week number extracted from planner event paths for weekly planner events.
{% enddocs %}


{% docs week_of_year_number %}
Week number of the year as an integer
{% enddocs %}


{% docs year_month_sort %}
Year and month in YY-MM format for chronological sorting (e.g., 25-01, 25-12, 26-01).
{% enddocs %}


{% docs year_number %}
Four-digit year number as an integer.
{% enddocs %}


{% docs year_quarter_sort %}
Year and quarter in YY-Q format for chronological sorting (e.g., 25-1, 25-4, 26-1), combining year and quarter values.
{% enddocs %}
