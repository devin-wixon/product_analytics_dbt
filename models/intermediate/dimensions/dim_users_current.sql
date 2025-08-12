with 

users as 
(select
    *
from
    {{ ref('stg_taco__users') }}
),

final as
(select
    *
from
    users
)

select
    *
from
    final
