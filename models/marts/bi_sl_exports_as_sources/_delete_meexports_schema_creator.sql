{{ config(
    materialized='table',
    schema='exports'
) }}

select 1 as dummy_column