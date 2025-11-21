{% macro is_distributed_demo_district(district_id) %}

    {#
        This macro identifies demo districts given to organizations to use during Back to School 2025 onboarding.
        
        ARGUMENTS:
        - district_id: The district ID to check (can be a column reference or literal value)
        
        DISTRIBUTED DEMO DISTRICTS:
        - 7871 | bts2025demo | Frog Street Back to School 2025 [expires 9/30/2025]
        - 7877 | bts2025tk | Back to School 2025 TK [expires 9/30/2025]  
        - 7870 | bts2025tx | Back to School 2025 Texas [expires 9/30/2025]
        
        BEHAVIOR:
        Returns a boolean case statement that evaluates to `true` if the district_id matches
        one of the three distributed demo districts, `false` otherwise.
        
        USAGE:
        select 
            district_id,
            {%raw%}{{ is_distributed_demo_district('district_id') }}{%endraw%} as is_distributed_demo_district
        from your_table
    #}

    case
        when {{ district_id }} in (7871, 7877, 7870) then true
        else false
    end

{% endmacro %}