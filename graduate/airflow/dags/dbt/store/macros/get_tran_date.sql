{% macro get_tran_date(date) %}
    to_timestamp(concat(date), 'MM/DD/YYYY')
{% endmacro %}
