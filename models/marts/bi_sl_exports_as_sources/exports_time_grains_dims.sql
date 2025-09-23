{{
  config(
    materialized='table',
    description='Unified table containing metrics at multiple time grains and dimension combinations for exports to allow for parameterization (ex: in Tableau). Generated dynamically from all semantic layer query exports.'
  )
}}

{#- Generate all CTEs using macro -#}
{%- set all_ctes = generate_all_export_ctes() %}

with

{{ all_ctes | join(',\n\n') }},

  final as (
      {{ generate_export_union() }}
  )

select *
from final