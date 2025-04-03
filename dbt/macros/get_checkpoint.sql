{% macro get_checkpoint(table_name) %}
    (
        select coalesce(
            (
                select max_value::timestamp
                from {{ source('meta', 'data_checkpoints') }}
                where table_name = '{{ table_name }}'
            ),
            '1900-01-01'::timestamp
        )
    )
{% endmacro %}
