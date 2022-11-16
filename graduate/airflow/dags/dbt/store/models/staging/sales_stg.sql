{%- set source_relation = adapter.get_relation(
        database=this.database ,
        schema=this.schema,
        identifier=this.name) -%}
{{
    config(
        materialized='incremental',
        pre_hook=[
            "delete from {{ this }} where tran_datetime::date = '{{ var('current_date') }}'" if source_relation else ""
        ]
    )
}}
select
    id,
    to_timestamp(concat(date, time), 'MM/DD/YYYYHH24:MI')  as tran_datetime,
    invoice_id,
    branch,
    city,
    customer_type,
    gender,
    product_line,
    unit_price,
    quantity,
    tax_5_percent,
    total,
    payment,
    cogs,
    gross_income,
    rating
from {{ source('raw_data', 'supermarket_sales') }} as tab
where to_timestamp(date, 'MM/DD/YYYY')::date = '{{ var("current_date") }}'
{% if is_incremental() %}
    and 1=1
{% endif %}
