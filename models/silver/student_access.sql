SELECT
    s.phone,
    s.school_name,
    COUNT(
        DISTINCT CASE
            WHEN REGEXP_CONTAINS(
                ta.flow_label,
                r'activity_access'
            ) THEN ta.flow_label
        END
    ) AS activities_accessed
FROM
    {{ ref('student_contacts') }} AS s
    LEFT JOIN {{ ref('total_activities') }} AS ta
        ON s.phone = ta.contact_phone
GROUP BY
    1,
    2
