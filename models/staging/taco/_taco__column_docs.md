{% docs application_name %}
Application name for third-party products such as Cognitive Toy Box.
{% enddocs %}


{% docs class_sourced_id %}
External class id, typically the class_id on the district SIS.
{% enddocs %}


{% docs class_status %}
Column is always either 'active' or null (as of 12/25).
{% enddocs %}


{% docs dbt_is_deleted %}
Boolean: True when the record is no longer in the source table, as tracked by dbt snapshots.
{% enddocs %}


{% docs dbt_scd_id %}
Unique identifier for the SCD2 snapshot row (managed by dbt).  
Example: 30d739da4641597758f41a2ac02b2f99
{% enddocs %}


{% docs dbt_updated_at %}
Timestamp when dbt detected a change and the snapshot row was created or inserted (column is created by dbt).  
Example: 2025-07-30 00:00:00.000
{% enddocs %}


{% docs dbt_valid_from %}
Timestamp when the snapshot row became valid (column is created by dbt).   
- **Timestamp strategy**: Comes from the source table's `updated_at` field (or configured timestamp column)
- **Check strategy**: Set to when dbt detected the change (will equal `dbt_updated_at`)
Example: 2025-07-30 00:00:00.000
{% enddocs %}


{% docs dbt_valid_to %}
Timestamp when the snapshot row became invalid (column is created by dbt).  
The current record for the table is identified by `dbt_valid_to is null`.  
Example: 9999-12-31 00:00:00.000
{% enddocs %}


{% docs district_address %}
Physical address of the district.  
Example: 123 Main St
{% enddocs %}


{% docs district_auto_rostering_checked_at %}
UTC timestamp of the most recent server check for files to sync for the district.”
{% enddocs %}


{% docs district_city %}
Example: Dallas
{% enddocs %}


{% docs district_general_settings %}
JSON of settings such as start date and end date
Example: {'end_date': '2026-06-25', 'start_date': '2025-06-25', 'classroom_schedule': {'friday': {}, 'monday': {}, 'sunday': {}, 'tuesday': {}, 'saturday': {}, 'thursday': {}, 'wednesday': {}}}
{% enddocs %}


{% docs district_id %}
Internal district identifier. May join to Salesforce district identifier data.
{% enddocs %}


{% docs district_identifier %}
Alternate identifier for the district, possibly for integration or mapping.  
Example: 67890
{% enddocs %}


{% docs district_mas_id %}
MAS system identifier for the district.  
Example: MAS98765
**Note** Historically, this was manually keyed in and may have errors.
{% enddocs %}


{% docs district_name %}
Example: Dallas ISD
{% enddocs %}


{% docs district_sage_id %}
Sage system identifier for the district.  
Example: SAGE54321
{% enddocs %}


{% docs district_sales_force_id %}
Salesforce identifier for the district.  
Example: SF12345
**Note** Prior to Dec 2025, this was manually keyed in and may have errors.
{% enddocs %}


{% docs district_settings %}
JSON of settings such as grades, rostering, and authentication methods
Example: {'grades': 'IT,PR,PK,TK,Other,KG,02', 'rostering': {'method': 'classlink', 'classlink_id': '1440', 'state_id_field': 'stateid', 'is_active_send_invite': 'false', 'allow_users_without_class_or_school': 'false'}, 'selfservice': {'rostering': {'show_clever': 'false'}, 'authentication': {'show_clever': 'true'}}, 'authentication': {'provider': 'class_link', 'classlink_settings': {'classlink_id': '1440'}}, 'product_launchers': {'aim_obs': {'url': '', 'enabled': True, 'access_key': '', 'private_key': ''}}, 'onboarding_required': 'false', 'user_pool_client_id': 'abcde'}
{% enddocs %}


{% docs district_sourced_id %}
External or source system identifier for the district, typically provided during a sync.
Example: 12345
{% enddocs %}


{% docs district_state %}
State where the district is located.  
Example: Louisiana
{% enddocs %}


{% docs district_state_international %}
Example: Brazilia
{% enddocs %}


{% docs district_type %}
Type of district.  

| Value             | Meaning                       |
|-------------------|------------------------------|
| small-independent | Small independent (ICC)    |
| international     | International district        |
| district          | School district          |
| head-start        | Head Start program            |
| demo-test         | District used for demonstrations or internal testing        |

{% enddocs %}


{% docs district_updated_at_utc %}
The last time a sync was received (`district_last_sync_utc`) _or_ a manual change was made to the district.
{% enddocs %}


{% docs district_website_slug %}
Website slug for the district. This is the subdomain for Lilypad in the URL (https://district_website_slug.lilypad2.frogstreet.com will be the URL).  
Example: dallas-isd
{% enddocs %}


{% docs enrollment_end_date %}
Optional column that is often null.
{% enddocs %}


{% docs enrollment_sourced_id %}
Row-level identifier of the enrollment record in the external system. Used by our system for value updates.
{% enddocs %}


{% docs enrollment_start_date %}
Optional column that is often null.
{% enddocs %}


{% docs enrollment_status %}
This is not used by Lilypad, as enrollment data is the most current provided by the user.
Values: active, tobedeleted
{% enddocs %}


{% docs is_disable_auto_sync %}
If true, any changes to the user will be ignored in following syncs.   
This applies to both new and existing users.  
This setting can be disabled in the user interface if needed.  
{% enddocs %}


{% docs is_district_auto_sync %}
Boolean: True if the district automatically syncs, overwriting any manually entered values.
Example: TRUE
{% enddocs %}


{% docs is_district_enabled %}
All values are TRUE as of 12/25.  Not persisted into warehouse models.
{% enddocs %}


{% docs is_enrollment_active %}
This is not used by our systems.
Values: always TRUE
{% enddocs %}


{% docs is_primary %}
If true, this is the primary teacher associated with the classroom; only one teacher per classroom can be primary. Used for third party applications that only allow one teacher per classroom.
{% enddocs %}


{% docs is_user_deleted %}
True if the user either has a deleted timestamp in Taco or the record was deleted and detected by dbt snapshots.
{% enddocs %}


{% docs license_start_date %}
The date the license becomes effective for user access.
Null means it is effective now and did not have a start date set.
{% enddocs %}



{% docs roster_file_created_at_utc %}
The most recent timestamp, if any, when the user requested an export of the roster.
{% enddocs %}


{% docs school_sourced_id %}
External school id, typically the school_id on the district SIS.
{% enddocs %}


{% docs school_status %}
Column is always either 'active' or null (as of 12/25).
{% enddocs %}


{% docs updated_at_utc %}
Timestamp of the last modification _or_ roster upload of the record in UTC.
This value may change if
* a record has a fresh roster upload that does _or_ does not change anything, or
* a record has a manual update that does _or_ does not change a column's value
Example: 2025-07-30 00:00:00.000
{% enddocs %}


{% docs user_deleted_at_utc %}
**Most deleted users will have a null value.**
Timestamp when the user was deleted in Taco. 
User deletions in Taco began to be tracked in Nov 2025. Prior to that, user history was captured via SCD2 snapshots starting in Sep 2025.
{% enddocs %}


{% docs user_email_sent_at_utc %}
The most recent date an invitation email was sent to the user. Administrators are shown the option to send invitation emails when users are created. Users may be invited by admins outside of Lilypad, so it will not have a value for all invited users.
- SSO (Classlink, Clever, Google, etc.): The email invites users to click the link to use their SSO credentials. Administrators may opt _not_ to automatically send emails because they use an application dashboard and not Lilypad's login flow.
- Username password: The email invites users to create a password.
- Districts may opt not to send automated invitation emails because their rostering system loads more users than those they intend to invite. 

Example: 2025-07-30 00:00:00.000
{% enddocs %}


{% docs user_grades %}
Array: Grade levels associated with the user.  
Example: ["IN", "TD", "PK"]
{% enddocs %}


{% docs user_id %}
Internal Frog Street unique identifier for the user record.  

**Note**: There are scenarios where a `user_id` may change for the same user. Examples: A district changes rostering methods to SSO, or moves from summer to academic year then back to academic year. Typically CS will do a conversion. However, if they just change the `user_sourced_id`, a new `user_id` will be created.

Example: 452698
{% enddocs %}


{% docs user_id_valid_from_sk %}
Surrogate key for user and the record's valid-from date, used for uniqueness and joins in user history models.
Example: 8e7c2a1b2f3d4e5f6a7b8c9d0e1f2a3b
{% enddocs %}


{% docs user_identifier %}
Alternate identifier for the user provided by the district, possibly for integration or mapping. 
Example: 19642
{% enddocs %}


{% docs user_invite_status %}
Indicates the onboarding status of the user.  

| Value        | Meaning                                                                 |
|------------- |------------------------------------------------------------------------|
| not_invited  | auth_method is username_password and invite e-mail not sent; occurs when administrators decline the option to auto-send user invites when a roster job is processed      |
| invited      | auth_method is username_password and invite e-mail sent            |
| sso          | auth_method is one of (clever, classlink, SAML, openid)           |
| registered   | auth_method is username_password and user completed registration and setting up their password   |
| backfill   | User was manually backfilled after deletion, and may have limited data other than district   |

Note: A user can change rostering methods. For example, an administrator may start with username password, then switch to SSO.
{% enddocs %}


{% docs user_role %}
Role of the user. Values are: teacher, administrator, student.  

Notes:
- Hierarchical visibility permissions are applied to school and district administrators.
    - A school administrator is defined as an administrator enrolled to a school.
    - A district administrator is defined as an administrator without any school enrollment.
- A teacher or student can be created without a class enrollment, but they are invalid and functionality such as sync to AIM or QR codes doesn't work. The `allow_users_without_class_or_school` district setting determines whether the district should allow invalid records to have functionality.
{% enddocs %}


{% docs user_role_id %}
Numeric identifier associated with the user role.
{% enddocs %}


{% docs user_sk %}
Surrogate key for the user, used for uniqueness and joins.
Example: 8e7c2a1b2f3d4e5f6a7b8c9d0e1f2a3b
{% enddocs %}


{% docs user_sourced_id %}
External user id, typically the user_id on the district SIS.
Example: 23308
{% enddocs %}


{% docs user_status %}
As of 2025-08, all values are "active" and the column is not useful.
{% enddocs %}
