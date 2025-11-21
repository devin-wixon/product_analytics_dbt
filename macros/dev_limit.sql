{% macro dev_limit(limit_rows=100) %}

    {#
        This macro applies a row limit in the Development environment to speed up model builds
        during development. In production and other environments, no limit is applied.

        ARGUMENTS:
        - limit_rows: Number of rows to limit to in Development (default: 100)

        BEHAVIOR:
        - In the 'Development' environment (when target.name == 'Development'):
          Applies a LIMIT clause with the specified number of rows, unless the runtime
          variable 'disable_dev_limit' is set to true or 'dev_limit_rows' overrides the default.

        - In other environments (prod, ci, etc.):
          Returns an empty string (no limit is applied).

        RUNTIME VARIABLES:
        - disable_dev_limit: Boolean. Set to true to disable all limits in Development.
          Example: dbt run --vars '{disable_dev_limit: true}'

        - dev_limit_rows: Integer. Override the default limit for all models that use dev_limit().
          Example: dbt run --vars '{dev_limit_rows: 500}'

        USAGE:
        select *
        from {{ ref('my_large_table') }}
        {{ dev_limit(100) }}

        -- Or use default 100 rows:
        select *
        from {{ ref('my_large_table') }}
        {{ dev_limit() }}
    #}

    {%- if target.name == 'Development' -%}
        {%- if var('disable_dev_limit', false) == false -%}
            {%- set final_limit = var('dev_limit_rows', limit_rows) -%}
            limit {{ final_limit }}
        {%- endif -%}
    {%- endif -%}

{% endmacro %}
