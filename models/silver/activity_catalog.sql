{{ config(
    materialized = "incremental",
    unique_key = ["contact_phone", "flow_label"]
) }}

SELECT
    contact_phone,
    flow_label,
    message_inserted_at
FROM
    {{ ref('total_activities') }}
WHERE
    contact_phone IS NOT NULL
    AND flow_label IS NOT NULL
    AND NOT REGEXP_CONTAINS(flow_label, r'(^|,\s*)Activity_Access(,|$)')
    AND NOT REGEXP_CONTAINS(flow_label, r'(^|,\s*)Activity_Submission(,|$)')
    AND NOT REGEXP_CONTAINS(flow_label, r'(^|,\s*)Activity_Complete(,|$)')

{% if is_incremental() %}
AND message_inserted_at > (
    SELECT
        COALESCE(
            MAX(message_inserted_at),
            DATETIME('1970-01-01')
        )
    FROM
        {{ this }}
)
{% endif %}
