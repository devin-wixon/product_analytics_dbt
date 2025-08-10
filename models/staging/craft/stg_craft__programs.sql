with
source_table as (
    select * from {{ source('craft', 'raw_craft__programs') }}
),

final as (
    select
        id::int as program_id,
        name::string as program_name,
        description::string as program_description,
        age_group::string as age_group,
        supplemental::boolean as is_supplemental,
        custom_banner::string as custom_banner,
        deleted_at::date as deleted_at_dt,
        clone_status::string as clone_status,
        type::string as program_type
    from source_table
)

select * from final
