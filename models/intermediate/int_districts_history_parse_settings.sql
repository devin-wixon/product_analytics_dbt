with

source as (
    select *
    from {{ ref('stg_taco__districts') }}
    where district_settings is not null
),

extracted_settings as (
    select
        *,

        -- Extract grades
        district_settings:rostering:classlink_id::string
            as rostering_classlink_id,

        -- Rostering settings
        district_settings:rostering:clever_id::string
            as rostering_clever_id,
        district_settings:rostering:upload_method::string
            as rostering_upload_method,
        district_settings:rostering:rostering_type::string
            as rostering_rostering_type,
        district_settings:rostering:state_id_field::string
            as rostering_state_id_field,
        district_settings:rostering:is_active_send_invite::string
            as rostering_is_active_send_invite,
        district_settings:rostering:allow_users_without_class_or_school::boolean
            as is_rostering_allow_users_without_class_or_school,
        district_settings:selfservice:rostering:show_clever::boolean
            as is_selfservice_rostering_show_clever,
        district_settings:selfservice:authentication:show_clever::boolean
            as is_selfservice_authentication_show_clever,

        -- Self-service settings
        district_settings:authentication:provider::string
            as authentication_provider,
        district_settings:authentication:login_field::string
            as authentication_login_field,

        -- Authentication settings
        district_settings:authentication:classlink_settings:classlink_id::string
            as authentication_classlink_settings_classlink_id,
        district_settings:authentication:clever_settings:clever_id::string
            as authentication_clever_settings_clever_id,

        -- Authentication ClassLink settings
        district_settings:authentication:clever_settings:provider_name::string
            as authentication_clever_settings_provider_name,

        -- Authentication Clever settings
        district_settings:authentication:saml_settings:provider_name::string
            as authentication_saml_settings_provider_name,
        district_settings:authentication:saml_settings:metadata_document_file::string
            as authentication_saml_settings_metadata_document_file,

        -- Authentication SAML settings
        district_settings:authentication:saml_settings:metadata_document_source::string
            as authentication_saml_settings_metadata_document_source,
        district_settings:onboarding_required::boolean
            as is_onboarding_required,
        district_settings:user_pool_client_id::string
            as user_pool_client_id,

        -- Onboarding and user pool
        coalesce(
            district_settings:grades::string,
            ''
        ) as district_grades,
        coalesce(
            district_settings:rostering:method::string,
            ''
        ) as rostering_method

    from source
),

final as (
    select *
    from extracted_settings
)

select *
from final
