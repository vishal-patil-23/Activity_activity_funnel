{{ config(
    materialized = "incremental",
    schema = "intermediate",
    unique_key = "phone"
) }}

WITH source_contacts AS (
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
                DATETIME('1970-01-01')
            )
        FROM
            {{ this }}
    )
    {% endif %}
)

SELECT
    phone,
    group_labels,
    raw_fields,
    inserted_at,
    updated_at
FROM
    source_contacts
QUALIFY
    ROW_NUMBER() OVER (
        PARTITION BY phone
        ORDER BY updated_at DESC, inserted_at DESC
    ) = 1
