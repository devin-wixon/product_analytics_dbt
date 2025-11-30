{% test orphaned_foreign_key_count(
    model, column_name, to, field, threshold, to_condition=None
    ) %}
{#
    Test that validates the count of orphaned foreign key values doesn't exceed a threshold.

    Arguments:
        model: The source model/relation being tested
        column_name: The foreign key column in the source model
        to: The reference model/relation (e.g., ref('parent_table'))
        field: The primary key column in the reference model
        threshold: Maximum number of distinct orphaned values allowed
        to_condition: Optional WHERE clause to filter the reference table (e.g., "dbt_valid_to IS NULL")

    Returns failing rows when the count of distinct orphaned foreign key values exceeds the threshold.

    Example usage:
        - orphaned_foreign_key_count:
            to: ref('stg_craft__resources')
            field: resource_id
            threshold: 714
            config:
              severity: warn
#}

    {{ config(severity='warn') }}

with source_table as (
    select distinct {{ column_name }} as fk_value
    from {{ model }}
    where {{ column_name }} is not null
),

reference_table as (
    select {{ field }} as pk_value
    from {{ to }}
    where {{ field }} is not null
    {% if to_condition %}
      and {{ to_condition }}
    {% endif %}
),

orphaned_values as (
    select source_table.fk_value
    from source_table
    left join reference_table
      on source_table.fk_value = reference_table.pk_value
    where reference_table.pk_value is null
),

orphan_count as (
    select
        count(distinct fk_value) as orphaned_count,
        {{ threshold }} as threshold
    from orphaned_values
)

select
    orphaned_count,
    threshold,
    orphaned_count - threshold as excess_orphans
from orphan_count
where orphaned_count > threshold

{% endtest %}
