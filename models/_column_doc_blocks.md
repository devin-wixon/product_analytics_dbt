{% docs district_name %}
Name of the district.  
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

{% docs district_last_sync %}
Timestamp of the last sync for the district.  
Example: 2025-07-30 00:00:00.000
{% enddocs %}

{% docs district_curriculum %}
Curriculum used by the district.  
Example: Common Core
{% enddocs %}

{% docs district_type %}
Type of district.  

| Value             | Meaning                       |
|-------------------|------------------------------|
| purchasing        | Purchasing entity            |
| small-independent | Small independent (ICC)    |
| international     | International district        |
| district          | School district          |
| head-start        | Head Start program            |
| demo-test         | Demo or test         |

Example: district
{% enddocs %}

{% docs district_settings %}
Serialized settings or preferences for the district.  
Example: {"key": "value"}
{% enddocs %}

{% docs district_enabled %}
Indicates if the district is enabled.  
Example: TRUE
{% enddocs %}

{% docs district_website_slug %}
Website slug for the district.  
Example: dallas-isd
{% enddocs %}

{% docs district_city %}
City where the district is located.  
Example: Dallas
{% enddocs %}

{% docs district_date_last_modified %}
Timestamp of the last modification to the district record in UTC.  
Example: 2025-07-30 00:00:00.000
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

{% docs district_auto_sync %}
Indicates if automatic synchronization is enabled for the district.  
Example: TRUE
{% enddocs %}

{% docs district_state_international %}
International state or region for the district.  
Example: Ontario
{% enddocs %}

{% docs district_general_settings %}
General settings for the district, stored as a variant.  
Example: {"setting": "value"}
{% enddocs %}


{% docs user_id %}
Unique identifier for the user record.  
Example: 452698
{% enddocs %}


{% docs user_sourced_id %}
External or source system identifier for the user.  
Example: 23308
{% enddocs %}


{% docs user_grades %}
Array: Grade levels associated with the user.  
Example: ["08"]
{% enddocs %}


{% docs user_identifier %}
Alternate identifier for the user provided by the district, possibly for integration or mapping. 
Example: 19642
{% enddocs %}


{% docs role %}
Role of the user. Values are: teacher, admin, student.  
Example: student
{% enddocs %}


{% docs user_status %}
Current status of the user (e.g., active, inactive).  
Example: active
{% enddocs %}


{% docs username %}
Username for user login or authentication.  
Example: (empty)
{% enddocs %}


{% docs okta_user_id %}
Identifier for the user in Okta (SSO provider).  
Example: (empty)
{% enddocs %}


{% docs class_id %}
Identifier for the class the user is associated with.  
Example: 11
{% enddocs %}


{% docs user_email_sent %}
Timestamp when an email was sent to the user.  
Example: 2025-07-30 00:00:00.000
{% enddocs %}


{% docs district_id %}
Identifier for the district the user belongs to.  
Example: (empty)
{% enddocs %}


{% docs date_last_modified %}
Timestamp of the last modification to the record in UTC.
Example: 2025-07-30 00:00:00.000
{% enddocs %}


{% docs phone %}
Phone number associated with the user.  
Example: (empty)
{% enddocs %}


{% docs user_other_grades %}
Other grade levels associated with the user.  
Example: (empty)
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


{% docs disable_auto_sync %}
Indicates if automatic synchronization is disabled for the user.  
Example: FALSE
{% enddocs %}


{% docs manually_added %}
Indicates if the user was manually added.  
Example: FALSE
{% enddocs %}


{% docs user_contact_email %}
Contact email address for the user.  
Example: (empty)
{% enddocs %}


{% docs override_district_auth %}
Indicates if district authentication is overridden for the user.  
Example: (empty)
{% enddocs %}


{% docs role_id %}
Identifier for the user's role.  
Example: (empty)
{% enddocs %}


{% docs user_settings %}
Serialized settings or preferences for the user.  
Example: (empty)
{% enddocs %}


{% docs user_state_id %}
State-level identifier for the user.  
Example: (empty)
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
