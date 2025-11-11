with
source_table as (
    select *
    from
        {{ ref('snp_taco__users') }}
),

final as (
    select
        id::int as user_id,
        district_id::int as district_id,

        role::string as user_role,
        sourced_id::string as user_sourced_id,
        identifier::string as user_identifier,
        disable_auto_sync::boolean as is_disable_auto_sync,

        manually_added::boolean as is_manually_added,
        invite_status::string as user_invite_status,

        -- timestamps
        email_sent::timestamp as user_email_sent_at_utc,
        updated_at::timestamp as user_updated_at_utc,
        created_at::timestamp as user_created_at_utc,
        deleted_at::timestamp as user_deleted_at_utc,

        -- snapshot columns
        dbt_scd_id,
        dbt_valid_from,
        dbt_valid_to,
        dbt_updated_at,
        dbt_is_deleted::boolean as dbt_is_deleted,
        dbt_is_deleted or user_deleted_at_utc is not null as is_user_deleted,

        -- can be Active or active
        lower(status::string) as user_status,
        case
            when grades = '' or grades is null then null
            -- array_compact removes null and [""]
            -- array cast allows parsing with Snowflake array functions
            else array_compact(try_parse_json(grades)::array)
        end as user_grades,
        case
            when other_grades = '' or other_grades is null then null
            when other_grades like '[(%)]'
                then
                    -- Fix [(PK)] format: extract content between parentheses
                    array_compact(array_construct(
                        regexp_replace(other_grades, '\\[\\((.*)\\)\\]', '\\1')
                    ))
            when other_grades like '%[%' and other_grades like '%]%'
                then
                    -- Fix JSON-like arrays: ["PREKINDERGARTEN"], ["PK3"], etc.
                    array_compact(try_parse_json(other_grades)::array)
            when other_grades like '%"%'
                then
                    -- Fix quoted strings that aren't arrays: "PREKINDERGARTEN"
                    array_compact(
                        array_construct(replace(other_grades, '"', ''))
                    )
            else
                -- Fix plain text strings: PREKINDERGARTEN, THREES, etc.
                array_compact(array_construct(other_grades))
        end as user_other_grades
    from source_table
)

-- reordering columns
select
    user_id,
    district_id,
    user_sourced_id,
    user_identifier,
    user_role,
    is_user_deleted,

    -- status and role attributes
    user_status,
    user_invite_status,
    user_grades,

    -- grade classifications
    user_other_grades,
    is_disable_auto_sync,

    -- boolean flags
    is_manually_added,
    user_created_at_utc,

    -- timestamps
    user_updated_at_utc,
    user_email_sent_at_utc,
    user_deleted_at_utc,
    dbt_scd_id,

    -- dbt snapshot columns
    dbt_updated_at,
    dbt_valid_from,
    dbt_valid_to,
    dbt_is_deleted


from
    final
