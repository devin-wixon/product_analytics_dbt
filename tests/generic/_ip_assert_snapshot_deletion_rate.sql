{% test assert_snapshot_deletion_rate(model, max_deletion_percentage=1) %}
{#
  Test to monitor deletion rates in dbt snapshots during daily batch processing.

  Purpose:
    - Detects when an unusually high percentage of daily snapshot changes are deletions
    - Helps identify potential data source issues or unexpected bulk deletion events

  How it works:
    - Counts total records updated in last 24 hours (dbt_updated_at >= current_date - 1)
    - Counts deletions using dbt_is_deleted = 'True' (string format, not boolean!)
    - Calculates deletion percentage: (deletions / total_changes) * 100
    - Alerts if deletion rate exceeds specified threshold

  Parameters:
    - max_deletion_percentage: Threshold percentage (default: 1%)

  Example alert scenarios:
    - Normal day: 2000 changes, 15 deletions = 0.75% → No alert
    - High deletion day: 2000 changes, 300 deletions = 15% → Alert triggered

  Note:
    - Only alerts when total_daily_changes > 10 to avoid false positives on low-volume days
    - Uses string format 'True' for dbt_is_deleted based on Snowflake testing
#}

with daily_changes as (
    select
        count(*) as total_daily_changes,
        count(case when dbt_is_deleted = true then 1 end) as daily_deletions
    from {{ target.database }}.{% if target.name == 'prod' %}snapshots{% else %}{{ target.schema }}{% endif %}.{{ model.name }}
    where dbt_updated_at >= current_date - 1
),

deletion_rate as (
    select
        total_daily_changes,
        daily_deletions,
        case
            when total_daily_changes > 0
            then (daily_deletions::float / total_daily_changes::float) * 100
            else 0
        end as deletion_percentage
    from daily_changes
)

select
    'Snapshot deletion rate anomaly detected' as alert_message,
    total_daily_changes,
    daily_deletions,
    deletion_percentage,
    {{ max_deletion_percentage }} as threshold_percentage
from deletion_rate
where deletion_percentage > {{ max_deletion_percentage }}
  and total_daily_changes > 10  -- Only alert if sufficient volume

{% endtest %}