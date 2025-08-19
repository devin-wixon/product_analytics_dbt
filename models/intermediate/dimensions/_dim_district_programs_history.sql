-- placeholder for future class dimension
{{ config(
    enabled = false
)}}

select
  1 as placeholder_column
from
  table(generator(rowcount => 1))