{{ config(materialized='table') }}

{%- set metrics_list = [] -%}

{%- for metric_name, metric in graph.metrics.items() -%}
    {%- set clean_description = (metric.description | replace("'", "") | replace('"', '') | replace('\n', ' ') | replace('\r', '') | truncate(200)) if metric.description else '' -%}
    {%- set clean_name = metric.name | replace("'", "") | replace('"', '') -%}
    {%- do metrics_list.append({
        'name': clean_name,
        'description': clean_description,
        'type': metric.type
    }) -%}
{%- endfor -%}

SELECT * FROM (
    VALUES 
    {%- for metric in metrics_list %}
        ('{{ metric.name }}', '{{ metric.description }}', '{{ metric.type }}', CURRENT_TIMESTAMP())
        {%- if not loop.last -%},{%- endif -%}
    {%- endfor %}
) AS metrics_glossary(metric_name, metric_description, metric_type, last_updated)