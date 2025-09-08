-- Audit Query for stg_taco__users grades transformation
-- This query compares the original grades string with the processed array
-- to ensure no grades are being dropped during the transformation

-- Create a CTE with both original and transformed data
WITH source_data AS (
    SELECT 
        id,
        grades AS original_grades,
        -- Apply the same transformation as in the model
        CASE
            WHEN grades IS NULL OR grades = '' THEN array_construct()
            ELSE parse_json(replace(replace(replace(grades, '''', '"'), '[""]', '[]'), '"s', 's'))
        END AS transformed_grades
    FROM {{ source('taco', 'raw_taco__users') }}
),

-- Extract all unique grade values from the original string
original_grades_parsed AS (
    SELECT 
        id,
        original_grades,
        -- Extract values by splitting string and removing formatting characters
        REGEXP_REPLACE(TRIM(value), '[\\[\\]\\''\\s]', '') AS original_grade_value
    FROM source_data,
    LATERAL SPLIT_TO_TABLE(
        REGEXP_REPLACE(
            REGEXP_REPLACE(original_grades, '\\[|\\]', ''), 
            '''', ''
        ), 
        ','
    )
    WHERE TRIM(value) != '' 
    AND original_grades IS NOT NULL 
    AND original_grades != ''
),

-- Count of grades in original data (after parsing)
original_counts AS (
    SELECT 
        id,
        original_grades,
        COUNT(DISTINCT original_grade_value) AS original_grade_count,
        ARRAY_AGG(DISTINCT original_grade_value) AS original_grade_array
    FROM original_grades_parsed
    GROUP BY id, original_grades
),

-- Count of grades in transformed array
transformed_counts AS (
    SELECT 
        id,
        transformed_grades,
        CASE 
            WHEN transformed_grades IS NULL THEN 0
            ELSE ARRAY_SIZE(transformed_grades) 
        END AS transformed_grade_count,
        transformed_grades AS transformed_grade_array
    FROM source_data
),

-- Special handling for NULL and empty values
null_empty_check AS (
    SELECT
        id,
        original_grades,
        CASE
            WHEN original_grades IS NULL THEN 'NULL'
            WHEN original_grades = '' THEN 'EMPTY'
            WHEN original_grades = '[]' THEN 'EMPTY_ARRAY'
            ELSE 'HAS_DATA'
        END AS original_status,
        transformed_grades,
        CASE
            WHEN transformed_grades IS NULL THEN 'NULL'
            WHEN ARRAY_SIZE(transformed_grades) = 0 THEN 'EMPTY_ARRAY'
            ELSE 'HAS_DATA'
        END AS transformed_status
    FROM source_data
    WHERE original_grades IS NULL 
       OR original_grades = '' 
       OR original_grades = '[]'
       OR transformed_grades IS NULL
       OR ARRAY_SIZE(transformed_grades) = 0
)

-- Main comparison query
SELECT 
    'POPULATED_VALUES' AS audit_section,
    o.id,
    o.original_grades,
    o.original_grade_count,
    o.original_grade_array,
    t.transformed_grade_count,
    t.transformed_grade_array,
    -- Flag records where counts don't match
    CASE 
        WHEN o.original_grade_count != t.transformed_grade_count THEN 'COUNT_MISMATCH'
        ELSE 'OK'
    END AS status,
    -- Calculate difference (missing grades)
    o.original_grade_count - t.transformed_grade_count AS missing_grade_count
FROM original_counts o
JOIN transformed_counts t ON o.id = t.id
-- Filter to only show problematic records (remove this WHERE clause to see all records)
WHERE o.original_grade_count != t.transformed_grade_count

UNION ALL

-- Check for NULL/empty handling
SELECT
    'NULL_EMPTY_VALUES' AS audit_section,
    id,
    original_grades,
    NULL AS original_grade_count,
    NULL AS original_grade_array,
    CASE 
        WHEN transformed_grades IS NULL THEN 0
        ELSE ARRAY_SIZE(transformed_grades) 
    END AS transformed_grade_count,
    transformed_grades AS transformed_grade_array,
    -- Flag any unexpected conversions
    CASE
        WHEN original_status IN ('NULL', 'EMPTY', 'EMPTY_ARRAY') AND transformed_status = 'NULL' THEN 'ERROR_SHOULD_BE_EMPTY_ARRAY'
        WHEN original_status IN ('NULL', 'EMPTY', 'EMPTY_ARRAY') AND transformed_status != 'EMPTY_ARRAY' THEN 'ERROR_UNEXPECTED_TRANSFORMATION'
        WHEN original_status = 'HAS_DATA' AND transformed_status = 'NULL' THEN 'ERROR_DATA_LOST'
        ELSE 'OK'
    END AS status,
    NULL AS missing_grade_count
FROM null_empty_check
WHERE original_status != transformed_status
   OR (transformed_status = 'NULL') -- Always flag NULL results

ORDER BY audit_section, missing_grade_count DESC;
