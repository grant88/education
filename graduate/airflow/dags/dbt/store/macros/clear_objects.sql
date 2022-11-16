{% macro clear_objects() %}
    {% set sql %}
        {% for tab in ['sales',
                        'customer_type',
                        'gender',
                        'payment',
                        'product_line',
                        'supercenter',
                        'sales_stg',
                        'transactions_monthly',
                        'transactions'] %}       
            drop TABLE IF EXISTS  store.{{tab}};
        {% endfor %}
    {% endset %}

    {% do run_query(sql) %}
    {% do log("Objects_cleared", info=True) %}
{% endmacro %}
