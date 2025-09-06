{% macro generate_schema_name(custom_schema_name, node) -%}

    {#-
        This macro generates a schema name for a model, allowing for different schemas
        between development and production environments.

        ARGUMENTS:
        - custom_schema_name: The schema name configured for the model in dbt_project.yml or the model's config block.
                              For example, a model in models/marts/my_model.sql might have `{{ config(schema='marts') }}`.
                              In this case, `custom_schema_name` would be 'marts'. If not provided, it's `None`.
        - node: The model's node object in the dbt graph.

        BEHAVIOR:
        - In the 'prod' environment (when target.name == 'prod'):
          The macro returns the `custom_schema_name` defined in the model's configuration.
          This ensures models are built in their specified production schemas (e.g., 'marts', 'staging').

        - In non-production environments (e.g., 'dev', 'qa'):
          The macro returns the `default_schema`, which is the schema defined in the developer's
          target in their `profiles.yml` file. This is a developer-specific schema, like 'dbt_dlw' where 'dlw' are a developer's initials.
          This prevents developers from accidentally writing to production schemas during development. All models will be built into this single
          developer-specific schema.
    -#}

    {%- set default_schema = target.schema -%}
    {%- if target.name == 'prod' -%}
        {%- if node.resource_type == 'seed' -%}
            seeds
        {%- else -%}
            {{ custom_schema_name | trim }} 
        {%- endif -%}
    {%- else -%}

        {{ default_schema }}

    {%- endif -%}

{%- endmacro %}