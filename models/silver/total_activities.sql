{{ config(
    materialized = "incremental",
    unique_key = ["contact_phone", "flow_label"]
) }}

SELECT
    contact_phone,
    flow_label,
    {# MAX(inserted_at) AS message_inserted_at #}
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

{% if is_incremental() %}
AND inserted_at > (
    SELECT
        COALESCE(
            MAX(message_inserted_at),
            DATETIME('1970-01-01')
        )
    FROM
        {{ this }}
)
{% endif %}

GROUP BY
    1,
    2
