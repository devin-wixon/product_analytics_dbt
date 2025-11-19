{% macro generate_incremental_batch_id() %}
    to_number(
        {% if is_incremental() %}
        ( select max(dbt_row_batch_id) + 1 from {{ this }} )
        {% else %}
        0
        {% endif %}
        , 38, 0
    ) as dbt_row_batch_id
{% endmacro %}
