-- models/marts/user_cohort_analysis.sql

{{ config(
    enabled=false
)}}

WITH base_events AS (
  SELECT 
    user_id,
    client_event_date,
    district_name,
    district_type,
    user_role,
    resource_type,
    program_name,
  FROM {{ ref('rpt_obt_events') }}
),

-- Join events to date spine to get all date grains
events_with_date_grains AS (
  SELECT 
    events.user_id,
    events.client_event_date,
    dates.date_day,
    dates.week_monday_date,

    -- Carry forward dimensions
    events.district_name,
    events.district_type,
    events.user_role,
    events.resource_type
  FROM base_events events
  INNER JOIN {{ ref('dim_day_datespine') }} dates
    ON events.client_event_date = dates.date_day
),

-- Create user activity by each grain (using UNION ALL)
user_periods AS (
  -- Weekly grain
  SELECT 
    user_id,
    week_monday_date AS date_grain,
    'Week' AS grain_type,
    COUNT(*) AS event_count,
    MIN(client_event_date) AS first_event_in_period,
    MAX(client_event_date) AS last_event_in_period,
    -- Take most frequent or first occurrence of dimensions
    MODE(district_name) AS district_name,
    MODE(district_type) AS district_type,
    MODE(user_role) AS user_role
  FROM events_with_date_grains
  GROUP BY user_id, week_monday_date
  
  UNION ALL
  
  -- Monthly grain  
  SELECT 
    user_id,
    month_date AS date_grain,
    'Month' AS grain_type,
    COUNT(*) AS event_count,
    MIN(client_event_date) AS first_event_in_period,
    MAX(client_event_date) AS last_event_in_period,
    MODE(district_name) AS district_name,
    MODE(district_type) AS district_type,
    MODE(user_role) AS user_role
  FROM events_with_date_grains
  GROUP BY user_id, month_date
  
  UNION ALL
  
  -- Quarterly grain
  SELECT 
    user_id,
    quarter_date AS date_grain,
    'Quarter' AS grain_type,
    COUNT(*) AS event_count,
    MIN(client_event_date) AS first_event_in_period,
    MAX(client_event_date) AS last_event_in_period,
    MODE(district_name) AS district_name,
    MODE(district_type) AS district_type,
    MODE(user_role) AS user_role
  FROM events_with_date_grains
  GROUP BY user_id, quarter_date
  
  UNION ALL
  
  -- Yearly grain
  SELECT 
    user_id,
    year_date AS date_grain,
    'Year' AS grain_type,
    COUNT(*) AS event_count,
    MIN(client_event_date) AS first_event_in_period,
    MAX(client_event_date) AS last_event_in_period,
    MODE(district_name) AS district_name,
    MODE(district_type) AS district_type,
    MODE(user_role) AS user_role
  FROM events_with_date_grains
  GROUP BY user_id, year_date
),

-- Add user first period and prior period calculations
with_period_context AS (
  SELECT 
    *,
    -- User's very first period for this grain type
    MIN(date_grain) OVER (PARTITION BY user_id, grain_type) AS user_first_period,
    
    -- Calculate what the prior period would be
    CASE 
      WHEN grain_type = 'Week' THEN date_grain - INTERVAL '1 week'
      WHEN grain_type = 'Month' THEN date_grain - INTERVAL '1 month'
      WHEN grain_type = 'Quarter' THEN date_grain - INTERVAL '3 months'
      WHEN grain_type = 'Year' THEN date_grain - INTERVAL '1 year'
    END AS prior_period_date
    
  FROM user_periods
),

-- Check if user was active in the prior period
final_cohort_classification AS (
  SELECT 
    curr.*,
    prior.user_id IS NOT NULL AS was_active_in_prior_period,
    
    -- New/Retain/Return classification
    CASE 
      WHEN curr.date_grain = curr.user_first_period THEN 'New'
      WHEN prior.user_id IS NOT NULL THEN 'Retain'
      ELSE 'Return'
    END AS user_cohort_classification
    
  FROM with_period_context curr
  LEFT JOIN with_period_context prior
    ON curr.user_id = prior.user_id
    AND curr.grain_type = prior.grain_type
    AND curr.prior_period_date = prior.date_grain
)

SELECT 
  user_id,
  date_grain,
  grain_type,
  user_cohort_classification,
  was_active_in_prior_period,
  user_first_period,
  prior_period_date,
  event_count,
  first_event_in_period,
  last_event_in_period,
  district_name,
  district_type,
  user_role
FROM final_cohort_classification
ORDER BY grain_type, date_grain, user_id