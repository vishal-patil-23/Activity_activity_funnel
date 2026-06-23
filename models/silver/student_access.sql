{{ config(
    materialized = "incremental",
    unique_key = ["phone", "school_name"]
) }}

WITH touched_phones AS (
    {% if is_incremental() %}
    SELECT
        phone
    FROM
        {{ ref('student_contacts') }}
    WHERE
        updated_at > (
            SELECT
                COALESCE(
                    MAX(refreshed_at),
                    DATETIME('1970-01-01')
                )
            FROM
                {{ this }}
        )

    UNION DISTINCT

    SELECT
        contact_phone AS phone
    FROM
        {{ ref('total_activities') }}
    WHERE
        message_inserted_at > (
            SELECT
                COALESCE(
                    MAX(refreshed_at),
                    DATETIME('1970-01-01')
                )
            FROM
                {{ this }}
        )
    {% else %}
    SELECT
        phone
    FROM
        {{ ref('student_contacts') }}
    {% endif %}
)

SELECT
    s.phone,
    s.school_name,
    COUNT(
        DISTINCT CASE
            WHEN REGEXP_CONTAINS(
                ta.flow_label,
                r'(?i)activity_access'
            ) THEN ta.flow_label
        END
    ) AS activities_accessed,
    GREATEST(
        MAX(s.updated_at),
        COALESCE(MAX(ta.message_inserted_at), DATETIME('1970-01-01'))
    ) AS refreshed_at
FROM
    {{ ref('student_contacts') }} AS s
    INNER JOIN touched_phones AS tp
        ON s.phone = tp.phone
    LEFT JOIN {{ ref('total_activities') }} AS ta
        ON s.phone = ta.contact_phone
GROUP BY
    1,
    2
