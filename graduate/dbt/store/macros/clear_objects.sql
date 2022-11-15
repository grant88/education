{% macro clear_objects() %}
{% set sql %}
    drop TABLE IF EXISTS  store.agg_by_product;
    
    drop TABLE IF EXISTS  store.sales;

    drop TABLE IF EXISTS  store.customer_type;
    drop TABLE IF EXISTS  store.gender;
    drop TABLE IF EXISTS  store.payment;
    drop TABLE IF EXISTS  store.product;
    drop TABLE IF EXISTS  store.supercenter;

    drop TABLE IF EXISTS  store.sales_stg;
{% endset %}

{% do run_query(sql) %}
{% do log("Objects_cleared", info=True) %}
{% endmacro %}
