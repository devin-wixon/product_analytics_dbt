{% macro generate_incremental_batch_id() -%}
    {#
        Generates a batch tracking ID for incremental models to track which rows were loaded in each run.

        ARGUMENTS:
        None

        BEHAVIOR:
        - On full refresh runs: Returns 0 as the batch_id
        - On incremental runs: Queries the existing table for max(dbt_row_batch_id) and adds 1
        - Returns a NUMBER(38,0) column named dbt_row_batch_id.
         Generates a batch tracking IDto track which rows were loaded in each run.  
         38 is a precision parameter allowing for large values without overflow.

        #}

    to_number(
        {% if is_incremental() %}
        ( select max(dbt_row_batch_id) + 1 from {{ this }} )
        {% else %}
        0
        {% endif %}
        , 38, 0
    ) as dbt_row_batch_id
{% endmacro %}
