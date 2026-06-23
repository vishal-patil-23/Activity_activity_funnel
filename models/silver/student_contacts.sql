{{ config(
    materialized = "incremental",
    unique_key = "phone"
) }}

SELECT
    phone,
    JSON_VALUE(raw_fields, '$.school.value') AS school_name,
    updated_at
FROM
    {{ ref('glific_contacts') }}
WHERE
    JSON_VALUE(raw_fields, '$.school.value') IS NOT NULL
    AND group_labels LIKE '%TLM25_AllStudents%'
    AND group_labels NOT LIKE '%TAP Team%'
    AND group_labels NOT LIKE '%TLM25_TAP%'
    AND phone NOT IN (
        '919886301830',
        '918564809100',
        '919068076307',
        '919325369003',
        '918448869330',
        '917988404006',
        '918858317341',
        '917620648785',
        '919999891797'
    )

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
