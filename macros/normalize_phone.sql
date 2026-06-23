{% macro normalize_phone(phone_column) %}
CASE
    WHEN LENGTH(REGEXP_REPLACE(CAST({{ phone_column }} AS STRING), r'[^0-9]', '')) = 10
        THEN CONCAT('91', REGEXP_REPLACE(CAST({{ phone_column }} AS STRING), r'[^0-9]', ''))
    ELSE REGEXP_REPLACE(CAST({{ phone_column }} AS STRING), r'[^0-9]', '')
END
{% endmacro %}
