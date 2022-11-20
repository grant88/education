{% macro get_tran_datetime(date, time) %}
    to_timestamp(concat(date, time), 'MM/DD/YYYYHH24:MI')
{% endmacro %}
