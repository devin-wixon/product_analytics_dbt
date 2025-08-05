with

refd as (
    select * from {{ ref('stg_lilypad__events_log') }}
),

final as (

    select
        -- Surrogate Key


        -- Dimension Keys


        -- Numeric Values        
        
        

        -- Dates (for simplicity)


    from refd

    left join dim_my_dim
        on refd.xx = dim_my_dim.xx

    left join dim_my_dim_2
        on refd.xx = dim_my_dim_2.xx



)

select * from final
