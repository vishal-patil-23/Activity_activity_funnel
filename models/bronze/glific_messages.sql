{{ config(
    materialized = "incremental"
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
        MAX(inserted_at)
    FROM
        {{ this }}
)
{% endif %}
