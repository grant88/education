{% macro make_constraints() %}
{% set sql %}
    {% for tab in ['payment', 'customer_type', 'gender', 'product_line', 'supercenter'] %}
        ALTER TABLE store.sales DROP CONSTRAINT IF EXISTS sales_{{tab}}_pk;
        ALTER TABLE store.{{tab}} DROP CONSTRAINT IF EXISTS {{tab}}_pk;

        ALTER TABLE store.{{tab}} ADD CONSTRAINT {{tab}}_pk PRIMARY KEY ({{tab}}_id);
        ALTER TABLE store.sales ADD CONSTRAINT sales_{{tab}}_fk FOREIGN KEY ({{tab}}_id) REFERENCES store.{{tab}}({{tab}}_id);
    {% endfor %}
{% endset %}

{% do run_query(sql) %}
{% do log("Constraints created", info=True) %}
{% endmacro %}
