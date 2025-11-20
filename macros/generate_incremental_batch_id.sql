{% macro generate_incremental_batch_id() %}

    {#-
        Generates a batch tracking ID for incremental models to track which rows were loaded in each run.

        ARGUMENTS:
        None

        BEHAVIOR:
        - On full refresh runs: Returns 0 as the batch_id
        - On incremental runs: Queries the existing table for max(dbt_row_batch_id) and adds 1
        - Returns a NUMBER(38,0) column named dbt_row_batch_id

        The precision of 38 is Snowflake's maximum for NUMBER type, ensuring the batch_id can handle
        extremely large values without overflow as it increments on each incremental run.

        USAGE:
        select
            *,
            {{ generate_incremental_batch_id() }}
        from {{ ref('my_source') }}
        {% if is_incremental() %}
        where event_date > (select max(event_date) from {{ this }})
        {% endif %}
    -#}

    to_number(
        {% if is_incremental() %}
        ( select max(dbt_row_batch_id) + 1 from {{ this }} )
        {% else %}
        0
        {% endif %}
        , 38, 0
    ) as dbt_row_batch_id
{% endmacro %}
