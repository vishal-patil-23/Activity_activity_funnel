{{ config(
    materialized = "incremental",
    unique_key = "phone"
) }}

WITH touched_phones AS (
    SELECT DISTINCT
        phone
    FROM
        {{ ref('student_access') }}

    {% if is_incremental() %}
    WHERE
        refreshed_at > (
            SELECT
                COALESCE(
                    MAX(refreshed_at),
                    DATETIME('1970-01-01')
                )
            FROM
                {{ this }}
        )

    UNION DISTINCT

    SELECT DISTINCT
        contact_phone AS phone
    FROM
        {{ ref('activity') }}
    WHERE
        refreshed_at > (
            SELECT
                COALESCE(
                    MAX(refreshed_at),
                    DATETIME('1970-01-01')
                )
            FROM
                {{ this }}
        )
    {% endif %}
)

SELECT
    sa.phone,
    sa.school_name,
    sa.activities_accessed,
    COALESCE(
        a.total_activity,
        0
    ) AS total_activity,
    CASE
        WHEN COALESCE(a.total_activity, 0) = 0 THEN NULL
        ELSE CAST(sa.activities_accessed AS FLOAT64) / a.total_activity
    END AS student_access_rate,
    GREATEST(
        sa.refreshed_at,
        COALESCE(a.refreshed_at, DATETIME('1970-01-01'))
    ) AS refreshed_at
FROM
    {{ ref('student_access') }} AS sa
    INNER JOIN touched_phones AS tp
        ON sa.phone = tp.phone
    LEFT JOIN {{ ref('activity') }} AS a
        ON sa.phone = a.contact_phone
