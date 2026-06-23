{{ config(
    materialized = "incremental",
    unique_key = "contact_phone"
) }}

WITH touched_phones AS (
    SELECT DISTINCT
        contact_phone
    FROM
        {{ ref('activity_catalog') }}

    {% if is_incremental() %}
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
    {% endif %}
)

SELECT
    ac.contact_phone,
    COUNT(*) AS total_activity,
    MAX(ac.message_inserted_at) AS refreshed_at
FROM
    {{ ref('activity_catalog') }} AS ac
    INNER JOIN touched_phones AS tp
        ON ac.contact_phone = tp.contact_phone
GROUP BY
    1
