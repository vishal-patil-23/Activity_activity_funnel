SELECT DISTINCT
    contact_phone,
    flow_label
FROM
    {{ ref('glific_messages') }}
WHERE
    flow_label IS NOT NULL
    AND REGEXP_CONTAINS(
        flow_label,
        r'(?i)(^|[^A-Za-z0-9])Activity([^A-Za-z0-9]|$)'
    )
    AND inserted_at >= DATETIME('2025-07-01')
    AND inserted_at < DATETIME('2026-07-01')
