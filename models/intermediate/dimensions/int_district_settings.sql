-- parse the district_settings column in stg_taco__districts

-- TAG TO DO This is a placeholder not debugged or audited
with
source as (
    select 
        district_id,
        district_settings
    from {{ ref('stg_taco__districts') }}
    where district_settings is not null
),

extracted_settings as (
    select
        district_id,
        
        -- Extract grades
        coalesce(district_settings:grades::string, '') as grades,
        
        -- Rostering settings
        coalesce(district_settings:rostering:method::string, '') as rostering_method,
        district_settings:rostering:classlink_id::string as rostering_classlink_id,
        district_settings:rostering:clever_id::string as rostering_clever_id,
        district_settings:rostering:upload_method::string as rostering_upload_method,
        district_settings:rostering:rostering_type::string as rostering_rostering_type,
        district_settings:rostering:state_id_field::string as rostering_state_id_field,
        district_settings:rostering:is_active_send_invite::string as rostering_is_active_send_invite,
        district_settings:rostering:allow_users_without_class_or_school::string as rostering_allow_users_without_class_or_school,
        
        -- Self-service settings
        district_settings:selfservice:rostering:show_clever::string as selfservice_rostering_show_clever,
        district_settings:selfservice:authentication:show_clever::string as selfservice_authentication_show_clever,
        
        -- Authentication settings
        district_settings:authentication:provider::string as authentication_provider,
        district_settings:authentication:login_field::string as authentication_login_field,
        
        -- Authentication ClassLink settings
        district_settings:authentication:classlink_settings:classlink_id::string as authentication_classlink_settings_classlink_id,
        
        -- Authentication Clever settings
        district_settings:authentication:clever_settings:clever_id::string as authentication_clever_settings_clever_id,
        district_settings:authentication:clever_settings:provider_name::string as authentication_clever_settings_provider_name,
        
        -- Authentication SAML settings
        district_settings:authentication:saml_settings:provider_name::string as authentication_saml_settings_provider_name,
        district_settings:authentication:saml_settings:metadata_document_file::string as authentication_saml_settings_metadata_document_file,
        district_settings:authentication:saml_settings:metadata_document_source::string as authentication_saml_settings_metadata_document_source,
        
        -- Product launchers
        -- ABCmouse
        case 
            when district_settings:product_launchers:abcmouse:enabled::string is not null 
            then district_settings:product_launchers:abcmouse:enabled::string
            else null
        end as product_launchers_abcmouse_enabled,
        
        -- ABC Mouse (extended)
        case 
            when district_settings:product_launchers:abc_mouse:enabled::string is not null 
            then district_settings:product_launchers:abc_mouse:enabled::string
            when district_settings:product_launchers:abc_mouse:enabled::boolean is not null 
            then district_settings:product_launchers:abc_mouse:enabled::boolean::string
            else null
        end as product_launchers_abc_mouse_enabled,
        district_settings:product_launchers:abc_mouse:abc_group_id::string as product_launchers_abc_mouse_abc_group_id,
        district_settings:product_launchers:abc_mouse:abc_district_sourced_id::string as product_launchers_abc_mouse_abc_district_sourced_id,
        
        -- CCEI
        case 
            when district_settings:product_launchers:ccei:enabled::string is not null 
            then district_settings:product_launchers:ccei:enabled::string
            when district_settings:product_launchers:ccei:enabled::boolean is not null 
            then district_settings:product_launchers:ccei:enabled::boolean::string
            else null
        end as product_launchers_ccei_enabled,
        
        -- Cognitive Box
        case 
            when district_settings:product_launchers:cognitive_box:enabled::string is not null 
            then district_settings:product_launchers:cognitive_box:enabled::string
            when district_settings:product_launchers:cognitive_box:enabled::boolean is not null 
            then district_settings:product_launchers:cognitive_box:enabled::boolean::string
            else null
        end as product_launchers_cognitive_box_enabled,
        district_settings:product_launchers:cognitive_box:api_key::string as product_launchers_cognitive_box_api_key,
        district_settings:product_launchers:cognitive_box:api_key_value::string as product_launchers_cognitive_box_api_key_value,
        
        -- Frog Street Pre-K
        case 
            when district_settings:product_launchers:frogstreet_prek:enabled::string is not null 
            then district_settings:product_launchers:frogstreet_prek:enabled::string
            when district_settings:product_launchers:frogstreet_prek:enabled::boolean is not null 
            then district_settings:product_launchers:frogstreet_prek:enabled::boolean::string
            else null
        end as product_launchers_frogstreet_prek_enabled,
        district_settings:product_launchers:frogstreet_prek:memberships::variant as product_launchers_frogstreet_prek_memberships,
        
        -- AIM CRT
        case 
            when district_settings:product_launchers:aim_crt:enabled::string is not null 
            then district_settings:product_launchers:aim_crt:enabled::string
            when district_settings:product_launchers:aim_crt:enabled::boolean is not null 
            then district_settings:product_launchers:aim_crt:enabled::boolean::string
            else null
        end as product_launchers_aim_crt_enabled,
        district_settings:product_launchers:aim_crt:url::string as product_launchers_aim_crt_url,
        district_settings:product_launchers:aim_crt:private_key::string as product_launchers_aim_crt_private_key,
        
        -- AIM OBS
        case 
            when district_settings:product_launchers:aim_obs:enabled::string is not null 
            then district_settings:product_launchers:aim_obs:enabled::string
            when district_settings:product_launchers:aim_obs:enabled::boolean is not null 
            then district_settings:product_launchers:aim_obs:enabled::boolean::string
            else null
        end as product_launchers_aim_obs_enabled,
        district_settings:product_launchers:aim_obs:url::string as product_launchers_aim_obs_url,
        district_settings:product_launchers:aim_obs:access_key::string as product_launchers_aim_obs_access_key,
        district_settings:product_launchers:aim_obs:private_key::string as product_launchers_aim_obs_private_key,
        
        -- CTB
        case 
            when district_settings:product_launchers:ctb:enabled::string is not null 
            then district_settings:product_launchers:ctb:enabled::string
            when district_settings:product_launchers:ctb:enabled::boolean is not null 
            then district_settings:product_launchers:ctb:enabled::boolean::string
            else null
        end as product_launchers_ctb_enabled,
        
        -- Ed-Fi
        case 
            when district_settings:product_launchers:edfi:enabled::string is not null 
            then district_settings:product_launchers:edfi:enabled::string
            when district_settings:product_launchers:edfi:enabled::boolean is not null 
            then district_settings:product_launchers:edfi:enabled::boolean::string
            else null
        end as product_launchers_edfi_enabled,
        district_settings:product_launchers:edfi:url::string as product_launchers_edfi_url,
        
        -- Keys not from inheritance
        district_settings:product_launchers:keys_not_from_inheritance::variant as product_launchers_keys_not_from_inheritance,
        
        -- Onboarding and user pool
        case 
            when district_settings:onboarding_required::string is not null 
            then district_settings:onboarding_required::string
            when district_settings:onboarding_required::boolean is not null 
            then district_settings:onboarding_required::boolean::string
            else 'false'
        end as onboarding_required,
        district_settings:user_pool_client_id::string as user_pool_client_id
    from source
),

final as (
    select
        district_id,
        
        -- Wrap individual settings into structured objects for better organization
        grades,
        
        -- Rostering settings object
        object_construct(
            'method', rostering_method,
            'classlink_id', rostering_classlink_id,
            'clever_id', rostering_clever_id,
            'upload_method', rostering_upload_method,
            'rostering_type', rostering_rostering_type,
            'state_id_field', rostering_state_id_field,
            'is_active_send_invite', rostering_is_active_send_invite,
            'allow_users_without_class_or_school', rostering_allow_users_without_class_or_school
        ) as rostering,
        
        -- Self-service settings object
        object_construct(
            'rostering', object_construct(
                'show_clever', selfservice_rostering_show_clever
            ),
            'authentication', object_construct(
                'show_clever', selfservice_authentication_show_clever
            )
        ) as selfservice,
        
        -- Authentication settings object
        object_construct(
            'provider', authentication_provider,
            'login_field', authentication_login_field,
            'classlink_settings', object_construct(
                'classlink_id', authentication_classlink_settings_classlink_id
            ),
            'clever_settings', object_construct(
                'clever_id', authentication_clever_settings_clever_id,
                'provider_name', authentication_clever_settings_provider_name
            ),
            'saml_settings', object_construct(
                'provider_name', authentication_saml_settings_provider_name,
                'metadata_document_file', authentication_saml_settings_metadata_document_file,
                'metadata_document_source', authentication_saml_settings_metadata_document_source
            )
        ) as authentication,
        
        -- Product launchers settings object
        object_construct(
            'abcmouse', object_construct(
                'enabled', product_launchers_abcmouse_enabled
            ),
            'abc_mouse', object_construct(
                'enabled', product_launchers_abc_mouse_enabled,
                'abc_group_id', product_launchers_abc_mouse_abc_group_id,
                'abc_district_sourced_id', product_launchers_abc_mouse_abc_district_sourced_id
            ),
            'ccei', object_construct(
                'enabled', product_launchers_ccei_enabled
            ),
            'cognitive_box', object_construct(
                'enabled', product_launchers_cognitive_box_enabled,
                'api_key', product_launchers_cognitive_box_api_key,
                'api_key_value', product_launchers_cognitive_box_api_key_value
            ),
            'frogstreet_prek', object_construct(
                'enabled', product_launchers_frogstreet_prek_enabled,
                'memberships', product_launchers_frogstreet_prek_memberships
            ),
            'aim_crt', object_construct(
                'enabled', product_launchers_aim_crt_enabled,
                'url', product_launchers_aim_crt_url,
                'private_key', product_launchers_aim_crt_private_key
            ),
            'aim_obs', object_construct(
                'enabled', product_launchers_aim_obs_enabled,
                'url', product_launchers_aim_obs_url,
                'access_key', product_launchers_aim_obs_access_key,
                'private_key', product_launchers_aim_obs_private_key
            ),
            'ctb', object_construct(
                'enabled', product_launchers_ctb_enabled
            ),
            'edfi', object_construct(
                'enabled', product_launchers_edfi_enabled,
                'url', product_launchers_edfi_url
            ),
            'keys_not_from_inheritance', product_launchers_keys_not_from_inheritance
        ) as product_launchers,
        
        onboarding_required,
        user_pool_client_id
    from extracted_settings
)

select * from final
