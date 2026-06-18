{{ config(
    materialized = "incremental",
    schema = "intermediate",
    unique_key = "phone"
) }}

SELECT
    phone,
    group_labels,
    raw_fields,
    inserted_at,
    updated_at
FROM
    {{ source(
        "glific",
        "contacts"
    ) }}
WHERE
    phone IS NOT NULL

{% if is_incremental() %}
AND updated_at > (
    SELECT
        COALESCE(
            MAX(updated_at),
            TIMESTAMP('1970-01-01')
        )
    FROM
        {{ this }}
)
{% endif %}
