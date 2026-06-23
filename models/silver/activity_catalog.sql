SELECT DISTINCT
    contact_phone,
    flow_label
FROM
    {{ ref('total_activities') }}
WHERE
    contact_phone IS NOT NULL
    AND flow_label IS NOT NULL
    AND NOT REGEXP_CONTAINS(flow_label, r'(^|,\s*)Activity_Access(,|$)')
    AND NOT REGEXP_CONTAINS(flow_label, r'(^|,\s*)Activity_Submission(,|$)')
    AND NOT REGEXP_CONTAINS(flow_label, r'(^|,\s*)Activity_Complete(,|$)')
