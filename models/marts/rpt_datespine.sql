with
datespine as (
    select *
    from {{ ref('dim_day_datespine') }}

),

final as (
    select *
    from datespine
)

select *
from final
