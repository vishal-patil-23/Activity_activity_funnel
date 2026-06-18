{{ config(
    materialized = "table",
    schema = "intermediate"
) }}

SELECT
    contact_phone,
    flow_label
FROM
    {{ ref('total_activities') }}
WHERE
    NOT REGEXP_CONTAINS(
        flow_label,
        r'Activity_Access'
    )
    AND NOT REGEXP_CONTAINS(
        flow_label,
        r'Activity_Submission'
    )
    AND NOT REGEXP_CONTAINS(
        flow_label,
        r'Activity_Complete'
    )
