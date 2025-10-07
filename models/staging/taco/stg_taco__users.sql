with
source_table as (
    select 
        * 
    from 
        {{ ref('snp_taco__users')}}
),

final as (
    select
        -- key info
        id::int as user_id,
        district_id::int as district_id,

        -- attributes
        role::string as user_role,
        sourced_id::string as user_sourced_id,
        identifier::string as user_identifier,
        disable_auto_sync::boolean as is_disable_auto_sync,

        -- identifiers
        manually_added::boolean as is_manually_added,
        invite_status::string as user_invite_status,
        -- status: standardizing capitalization (it's mixed ACTIVE, active, Active)
        lower(status::string) as user_status,

        case
            when grades = '' or grades is null then null
            -- array_compact removes null and [""]
            -- array cast allows parsing with Snowflake array functions
            else array_compact(try_parse_json(grades)::array)
        end as user_grades,

        -- other_grades mixes JSON-like arrays and plain text
        case
            when other_grades = '' or other_grades is null then null
            when other_grades like '[(%)]'
                then
                    -- Handle [(PK)] format: extract content between parentheses
                    array_compact(array_construct(
                        regexp_replace(other_grades, '\\[\\((.*)\\)\\]', '\\1')
                    ))
            when other_grades like '%[%' and other_grades like '%]%'
                then
                    -- Handle JSON-like arrays: ["PREKINDERGARTEN"], ["PK3"], etc.
                    array_compact(try_parse_json(other_grades)::array)
            when other_grades like '%"%'
                then
                    -- Handle quoted strings that aren't arrays: "PREKINDERGARTEN"
                    array_compact(
                        array_construct(replace(other_grades, '"', ''))
                    )
            else
                -- Handle plain text strings: PREKINDERGARTEN, THREES, etc.
                array_compact(array_construct(other_grades))
        end as user_other_grades,
        
        -- timestamps
        -- deleted_at::timestamp as deleted_at_utc -- null in all columns of source 080825
        email_sent::timestamp as user_email_sent_at_utc,
        updated_at::timestamp as user_updated_at_utc,
        created_at::timestamp as user_created_at_utc,

        -- snapshot columns
        dbt_scd_id,
        dbt_valid_from,
        dbt_valid_to,
        dbt_updated_at,
        dbt_is_deleted::boolean as dbt_is_deleted
    from source_table
)

select 
    * 
from 
    final
