with
source_table as (
    select *
    from
        {{ source('taco', 'raw_taco__classes') }}
),

final as (
    select
        id::int as class_id,
        name::string as class_name,
        school_id::int as school_id,
        district_id::int as district_id,

        -- boolean
        disable_auto_sync::boolean
            as is_class_disable_auto_sync,
        manually_added::boolean as is_class_manually_added,

        -- attributes
        settings::string as class_settings,
        sourced_id::string as class_sourced_id,
        term::string as term_id,
        class_code::string as class_code,
        class_type::string as class_type,
        school_sourced_id::string as school_sourced_id,
        status::string as class_status,
        location::string as class_location,
        grades::string as class_grades,
        other_grades::string as other_grades,
        subjects::string as class_subjects,
        subject_codes::string as class_subject_codes,
        periods::string as class_periods,
        course_id::int as class_course_id,
        course_sourced_id::string as class_course_sourced_id,

        -- timestamps
        qrcodes_pdf_created_at::timestamp
            as qrcodes_pdf_created_at_utc,
        created_at::timestamp as class_created_at_utc,
        updated_at::timestamp as class_updated_at_utc
    from source_table
)

select *
from
    final
