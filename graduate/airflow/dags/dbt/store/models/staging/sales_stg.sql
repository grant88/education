{%- set source_relation = adapter.get_relation(
        database=this.database ,
        schema=this.schema,
        identifier=this.name) -%}
{{
    config(
        materialized='incremental',
        pre_hook=[
            "delete from {{ this }} where tran_datetime::date = '{{ var('current_date') }}'::date" if source_relation else ""
        ]
    )
}}
select
    id,
    {{ get_tran_datetime(date, time) }} as tran_datetime,
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
where {{ get_tran_date(date) }} = '{{ var("current_date") }}'::date
{% if is_incremental() %}
    and 1=1
{% endif %}
