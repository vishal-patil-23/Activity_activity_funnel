{{ config(
    materialized = "table",
    schema = "intermediate"
) }}

SELECT
    sa.phone,
    sa.school_name,
    sa.activities_accessed,
    COALESCE(
        a.total_activity,
        0
    ) AS total_activity,
    SAFE_DIVIDE(sa.activities_accessed, a.total_activity) AS student_access_rate
FROM
    {{ ref('student_access') }} AS sa
    LEFT JOIN {{ ref('activity') }} AS a
        ON sa.phone = a.contact_phone
