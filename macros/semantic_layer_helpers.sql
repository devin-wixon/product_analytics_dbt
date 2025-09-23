{#
    Semantic Layer Helper Macros

    Purpose: Generate dimension combinations and saved queries dynamically
    for scalable Tableau parameterization across time grains and dimensions.
#}

{# Configuration for dimensions and time grains #}
{% macro get_tableau_dimensions() %}
    {% set dimensions = [
        {'name': 'program_name', 'label': 'Program name', 'semantic_ref': 'program__program_name'},
        {'name': 'resource_type', 'label': 'Resource type', 'semantic_ref': 'resource__resource_type'},
        {'name': 'district_name', 'label': 'District name', 'semantic_ref': 'district__district_name'},
        {'name': 'district_type', 'label': 'District type', 'semantic_ref': 'district__district_type'},
        {'name': 'launched_application_name', 'label': 'Application name', 'semantic_ref': 'event__launched_application_name'}
    ] %}
    {{ return(dimensions) }}
{% endmacro %}

{% macro get_time_grains() %}
    {% set time_grains = [
        {'name': 'day', 'semantic_ref': 'event__metric_time_day'},
        {'name': 'week', 'semantic_ref': 'event__metric_time_week'},
        {'name': 'month', 'semantic_ref': 'event__metric_time_month'}
    ] %}
    {{ return(time_grains) }}
{% endmacro %}

{% macro get_tableau_metrics() %}
    {% set metrics = ['n_active_users', 'n_events'] %}
    {{ return(metrics) }}
{% endmacro %}

{# Generate all single dimension combinations #}
{% macro get_single_dimension_combinations() %}
    {% set dimensions = get_tableau_dimensions() %}
    {% set combinations = [] %}

    {% for dim in dimensions %}
        {% set combo = {
            'id': dim.name,
            'label': dim.label,
            'dimensions': [dim]
        } %}
        {% set _ = combinations.append(combo) %}
    {% endfor %}

    {{ return(combinations) }}
{% endmacro %}

{# Generate all 2x dimension combinations #}
{% macro get_two_dimension_combinations() %}
    {% set dimensions = get_tableau_dimensions() %}
    {% set combinations = [] %}

    {% for i in range(dimensions|length) %}
        {% for j in range(i + 1, dimensions|length) %}
            {% set dim_a = dimensions[i] %}
            {% set dim_b = dimensions[j] %}
            {% set combo = {
                'id': dim_a.name ~ '__' ~ dim_b.name,
                'label': dim_a.label ~ ' × ' ~ dim_b.label,
                'dimensions': [dim_a, dim_b]
            } %}
            {% set _ = combinations.append(combo) %}
        {% endfor %}
    {% endfor %}

    {{ return(combinations) }}
{% endmacro %}

{# Generate "all" (no dimensions) combination #}
{% macro get_all_dimensions_combination() %}
    {% set all_combo = {
        'id': 'all',
        'label': 'All (no dimensional breakdown)',
        'dimensions': []
    } %}
    {{ return(all_combo) }}
{% endmacro %}

{# Generate all dimension combinations (all + single + 2x) #}
{% macro get_all_dimension_combinations() %}
    {% set all_combo = [get_all_dimensions_combination()] %}
    {% set single_combos = get_single_dimension_combinations() %}
    {% set two_combos = get_two_dimension_combinations() %}
    {% set all_combos = all_combo + single_combos + two_combos %}
    {{ return(all_combos) }}
{% endmacro %}

{# Generate saved query configuration for a specific time grain and dimension combination #}
{% macro generate_saved_query_config(time_grain, dimension_combo) %}
    {% set metrics = get_tableau_metrics() %}
    {% set query_name = 'sq_' ~ time_grain.name ~ '_' ~ dimension_combo.id %}
    {% set export_name = 'qexptbl_' ~ time_grain.name ~ '_' ~ dimension_combo.id %}

    {% set config = {
        'name': query_name,
        'description': 'Metrics by ' ~ time_grain.name ~ ' and ' ~ dimension_combo.label,
        'query_params': {
            'metrics': metrics,
            'group_by': []
        },
        'exports': [{
            'name': export_name,
            'config': {
                'export_as': 'table',
                'schema': "{{ 'exports' if target.name == 'prod' else target.schema }}",
                'alias': export_name
            }
        }]
    } %}

    {# Add time dimension #}
    {% set time_dim = "TimeDimension('" ~ time_grain.semantic_ref ~ "', '" ~ time_grain.name ~ "')" %}
    {% set _ = config.query_params.group_by.append(time_dim) %}

    {# Add dimension(s) #}
    {% for dim in dimension_combo.dimensions %}
        {% set dim_ref = "Dimension('" ~ dim.semantic_ref ~ "')" %}
        {% set _ = config.query_params.group_by.append(dim_ref) %}
    {% endfor %}

    {{ return(config) }}
{% endmacro %}

{# Generate all saved query configurations #}
{% macro generate_all_saved_queries() %}
    {% set time_grains = get_time_grains() %}
    {% set dimension_combos = get_all_dimension_combinations() %}
    {% set all_queries = [] %}

    {% for time_grain in time_grains %}
        {% for dimension_combo in dimension_combos %}
            {% set query_config = generate_saved_query_config(time_grain, dimension_combo) %}
            {% set _ = all_queries.append(query_config) %}
        {% endfor %}
    {% endfor %}

    {{ return(all_queries) }}
{% endmacro %}

{# Generate CTE for tableau_time_grains_dims model #}
{% macro generate_tableau_cte(time_grain, dimension_combo) %}
    {% set cte_name = time_grain.name ~ '_' ~ dimension_combo.id %}
    {% set source_name = 'qexptbl_' ~ time_grain.name ~ '_' ~ dimension_combo.id %}
    {% set time_column = 'event__metric_time_' ~ time_grain.name ~ '__' ~ time_grain.name %}

    {% set cte_sql %}
  {{ cte_name }} as (
      select
          {{ time_column }} as date_at_time_grain,
          '{{ time_grain.name }}' as time_grain,
          '{{ dimension_combo.id }}' as dim_set,
          {%- if dimension_combo.dimensions|length == 0 %}
          'All' as dim_a_label,
          null as dim_b_label,
          'All' as dim_a_value,
          cast(null as varchar) as dim_b_value,
          {%- elif dimension_combo.dimensions|length == 1 %}
          '{{ dimension_combo.dimensions[0].label }}' as dim_a_label,
          null as dim_b_label,
          {{ dimension_combo.dimensions[0].semantic_ref }} as dim_a_value,
          cast(null as varchar) as dim_b_value,
          {%- else %}
          '{{ dimension_combo.dimensions[0].label }}' as dim_a_label,
          '{{ dimension_combo.dimensions[1].label }}' as dim_b_label,
          {{ dimension_combo.dimensions[0].semantic_ref }} as dim_a_value,
          {{ dimension_combo.dimensions[1].semantic_ref }} as dim_b_value,
          {%- endif %}
          n_active_users,
          n_events
      from
          {{ source('exports', source_name) }}
      {%- if dimension_combo.dimensions|length == 1 %}
      where
          {{ dimension_combo.dimensions[0].semantic_ref }} is not null
      {%- elif dimension_combo.dimensions|length == 2 %}
      where
          {{ dimension_combo.dimensions[0].semantic_ref }} is not null
          or {{ dimension_combo.dimensions[1].semantic_ref }} is not null
      {%- endif %}
  ){% endset %}

    {{ return(cte_sql) }}
{% endmacro %}

{# Generate all CTEs for tableau_time_grains_dims model #}
{% macro generate_all_tableau_ctes() %}
    {% set time_grains = get_time_grains() %}
    {% set dimension_combos = get_all_dimension_combinations() %}
    {% set all_ctes = [] %}

    {% for time_grain in time_grains %}
        {% for dimension_combo in dimension_combos %}
            {% set cte_sql = generate_tableau_cte(time_grain, dimension_combo) %}
            {% set _ = all_ctes.append(cte_sql) %}
        {% endfor %}
    {% endfor %}

    {{ return(all_ctes) }}
{% endmacro %}

{# Generate UNION ALL for tableau_time_grains_dims final CTE #}
{% macro generate_tableau_union() %}
    {% set time_grains = get_time_grains() %}
    {% set dimension_combos = get_all_dimension_combinations() %}
    {% set union_parts = [] %}

    {% for time_grain in time_grains %}
        {% for dimension_combo in dimension_combos %}
            {% set cte_name = time_grain.name ~ '_' ~ dimension_combo.id %}
            {% set _ = union_parts.append('select * from ' ~ cte_name) %}
        {% endfor %}
    {% endfor %}

    {{ return(union_parts | join('\n      union all\n      ')) }}
{% endmacro %}