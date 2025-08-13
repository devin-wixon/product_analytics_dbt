
{% docs district_name %}
Example: Dallas ISD
{% enddocs %}


{% docs district_address %}
Physical address of the district.  
Example: 123 Main St
{% enddocs %}


{% docs district_state %}
State where the district is located.  
Example: Louisiana
{% enddocs %}


{% docs district_sales_force_id %}
Salesforce identifier for the district.  
Example: SF12345
{% enddocs %}


{% docs district_mas_id %}
MAS system identifier for the district.  
Example: MAS98765
{% enddocs %}


{% docs district_sage_id %}
Sage system identifier for the district.  
Example: SAGE54321
{% enddocs %}


{% docs district_last_sync_utc %}
<!-- TAG TO DO confirm values and flesh out with their meaning. -->
Example: 2025-07-30 00:00:00.000
{% enddocs %}


{% docs district_type %}
Type of district.  

| Value             | Meaning                       |
|-------------------|------------------------------|
| small-independent | Small independent (ICC)    |
| international     | International district        |
| district          | School district          |
| head-start        | Head Start program            |
| demo-test         | Demo or test         |
{% enddocs %}

{% docs district_settings %}
JSON of settings such as grades, rostering, and authentication methods
Example: {'grades': 'IT,PR,PK,TK,Other,KG,02', 'rostering': {'method': 'classlink', 'classlink_id': '1440', 'state_id_field': 'stateid', 'is_active_send_invite': 'false', 'allow_users_without_class_or_school': 'false'}, 'selfservice': {'rostering': {'show_clever': 'false'}, 'authentication': {'show_clever': 'true'}}, 'authentication': {'provider': 'class_link', 'classlink_settings': {'classlink_id': '1440'}}, 'product_launchers': {'aim_obs': {'url': '', 'enabled': True, 'access_key': '', 'private_key': ''}}, 'onboarding_required': 'false', 'user_pool_client_id': 'abcde'}
{% enddocs %}


{% docs is_district_enabled %}
<!-- TAG TO DO confirm values and flesh out with their meaning. -->
{% enddocs %}


{% docs district_website_slug %}
Website slug for the district. This is the subdomain for Lilypad.  
Example: dallas-isd
{% enddocs %}


{% docs district_city %}
City where the district is located.  
Example: Dallas
{% enddocs %}


{% docs district_sourced_id %}
External or source system identifier for the district.  
Example: 12345
{% enddocs %}


{% docs district_identifier %}
Alternate identifier for the district, possibly for integration or mapping.  
Example: 67890
{% enddocs %}


{% docs district_roster_file_created_at %}
Timestamp when the district's roster file was created.  
Example: 2025-07-30 00:00:00.000
{% enddocs %}


{% docs district_auto_rostering_checked_at %}
Timestamp when auto rostering was last checked for the district.  
Example: 2025-07-30 00:00:00.000
{% enddocs %}


{% docs is_district_auto_sync %}
<!-- TAG TO DO confirm values and flesh out with their meaning. -->
Example: TRUE
{% enddocs %}


{% docs district_state_international %}
Example: Brazilia
{% enddocs %}


{% docs district_general_settings %}
JSON of settings such as start date and end date
Example: {'end_date': '2026-06-25', 'start_date': '2025-06-25', 'classroom_schedule': {'friday': {}, 'monday': {}, 'sunday': {}, 'tuesday': {}, 'saturday': {}, 'thursday': {}, 'wednesday': {}}}
{% enddocs %}


{% docs enrollment_sourced_id %}
Row-level identifier of the enrollment record in the external system. Used by our system for value updates.
{% enddocs %}


{% docs enrollment_end_date %}
Optional column that is often null.
{% enddocs %}


{% docs enrollment_id %}
{% enddocs %}


{% docs enrollment_start_date %}
Optional column that is often null.
{% enddocs %}


{% docs enrollment_status %}
This is not used by our systems.
Values: active, tobedeleted
{% enddocs %}

{% docs is_enrollment_active %}
This is not used by our systems.
Values: always TRUE
{% enddocs %}


{% docs is_primary %}
If true, this is the primary teacher associated with the classroom. Used for third party applications that only allow one teacher per classroom.
{% enddocs %}


{% docs user_role_id %}
Numeric identifier associated with the user role.
{% enddocs %}

{% docs user_id %}
Unique identifier for the user record.  
Example: 452698
{% enddocs %}

{% docs user_sk %}
Surrogate key for the user, used for uniqueness and joins.
Example: 8e7c2a1b2f3d4e5f6a7b8c9d0e1f2a3b
{% enddocs %}


{% docs user_id_valid_from_sk %}
Surrogate key for user and the record's valid-from date, used for uniqueness and joins in user history models.
Example: 8e7c2a1b2f3d4e5f6a7b8c9d0e1f2a3b
{% enddocs %}


{% docs user_sourced_id %}
External user id, typically the user_id on the district SIS.
Example: 23308
{% enddocs %}


{% docs user_grades %}
Array: Grade levels associated with the user.  
Example: ["IN", "TD", "PK"]
{% enddocs %}


{% docs user_identifier %}
Alternate identifier for the user provided by the district, possibly for integration or mapping. 
Example: 19642
{% enddocs %}


{% docs user_role %}
Role of the user. Values are: teacher, administrator, student.  
Example: student
{% enddocs %}


{% docs user_status %}
As of 2025-08, all values are "active" and the column is not useful.
{% enddocs %}


{% docs username %}
{% enddocs %}


{% docs okta_user_id %}
Identifier for the user in Okta (SSO provider).  
Example: (empty)
{% enddocs %}


{% docs class_id %}
{% enddocs %}

{% docs class_sourced_id %}
External class id, typically the class_id on the district SIS.
{% enddocs %}


{% docs school_id %}
{% enddocs %}

{% docs school_sourced_id %}
External school id, typically the school_id on the district SIS.
{% enddocs %}


{% docs email_sent_utc %}
Timestamp when an email was sent to the user.  
Example: 2025-07-30 00:00:00.000
{% enddocs %}


{% docs district_id %}
{% enddocs %}


{% docs last_modified_at_utc %}
Timestamp of the last modification to the record in UTC.
Example: 2025-07-30 00:00:00.000
{% enddocs %}


{% docs phone %}
{% enddocs %}


{% docs user_other_grades %}
<!-- TAG TO DO confirm values and flesh out with their meaning. -->
{% enddocs %}


{% docs is_disable_auto_sync %}
If true, any changes to the user will be ignored in following syncs.   
This applies to both new and existing users.  
This setting can be disabled in the user interface if needed.  
{% enddocs %}


{% docs user_invite_status %}
Indicates the onboarding status of the user.  

| Value        | Meaning                                                                 |
|------------- |------------------------------------------------------------------------|
| not_invited  | When auth_method is username_password and invite e-mail not sent        |
| invited      | When auth_method is username_password and invite e-mail sent            |
| sso          | When auth_method is one of (clever, classlink, SAML, openid)           |
| registered   | When auth_method is username_password and user completed registration and setting up their password   |
{% enddocs %}


{% docs is_manually_added %}
{% enddocs %}


{% docs user_contact_email %}
{% enddocs %}


{% docs override_district_auth %}
{% enddocs %}


{% docs user_settings %}
{% enddocs %}


{% docs user_state_id %}
{% enddocs %}


{% docs dbt_scd_id %}
Unique identifier for the SCD2 snapshot row (managed by dbt).  
Example: 30d739da4641597758f41a2ac02b2f99
{% enddocs %}


{% docs dbt_updated_at %}
Timestamp when the snapshot row was last updated (managed by dbt).  
Example: 2025-07-30 00:00:00.000
{% enddocs %}


{% docs dbt_valid_from %}
Timestamp when the snapshot row became valid (managed by dbt).  
Example: 2025-07-30 00:00:00.000
{% enddocs %}


{% docs dbt_valid_to %}
Timestamp when the snapshot row became invalid (managed by dbt).  
Example: 9999-12-31 00:00:00.000
{% enddocs %}


{% docs dbt_is_deleted %}
Indicates if the record is considered deleted (managed by dbt).  
Example: False
{% enddocs %}
