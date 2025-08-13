{% docs authentication_classlink_settings_classlink_id %}
ClassLink organization identifier for authentication.
{% enddocs %}

{% docs authentication_clever_settings_clever_id %}
Clever district identifier for authentication.
{% enddocs %}

{% docs authentication_clever_settings_provider_name %}
Human-readable name of the Clever provider/district.
{% enddocs %}

{% docs authentication_login_field %}
Field used for user login identification.
{% enddocs %}

{% docs authentication_provider %}
Primary authentication provider for the district.
{% enddocs %}

{% docs authentication_saml_settings_metadata_document_file %}
File path or name of the SAML metadata document.
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

{% docs is_onboarding_required %}
True means admins (with permission) will be redirected to onboarding as soon they login while other users will be redirected to an error page
{% enddocs %}

{% docs is_rostering_allow_users_without_class_or_school %}
{% enddocs %}

{% docs rostering_classlink_id %}
{% enddocs %}

{% docs rostering_clever_id %}
{% enddocs %}

{% docs rostering_is_active_send_invite %}
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

{% docs folder_id %}
{% enddocs %}

{% docs framework_id %}
{% enddocs %}

{% docs focus_area_id %}
{% enddocs %}
