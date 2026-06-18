{{ config(
    materialized = "table",
    schema = "intermediate"
) }}

SELECT
    contact_phone,
    COUNT(*) AS total_activity
FROM
    {{ ref('activity_catalog') }}
GROUP BY
    1
