{{ config(
    materialized = "incremental",
    unique_key = ["contact_phone", "flow_label", "inserted_at"]
) }}

SELECT
    contact_phone,
    flow_label,
    inserted_at
FROM
    {{ source(
        "glific",
        "messages"
    ) }}
WHERE
    contact_phone IS NOT NULL

{% if is_incremental() %}
AND inserted_at > (
    SELECT
        COALESCE(
            MAX(inserted_at),
            DATETIME('1970-01-01')
        )
    FROM
        {{ this }}
)
{% endif %}
