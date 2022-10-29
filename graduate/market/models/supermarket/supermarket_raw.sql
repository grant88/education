{{
    config(
        materialized='incremental'
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
    gross_margin_percentage,
    gross_income,
    rating
from {{ source('supermarket_sales', 'sales') }} as tab
{% if is_incremental() %}
    where to_timestamp(concat(date, time), 'MM/DD/YYYYHH24:MI') >= (select max(tran_datetime) from {{this}})
{% endif %}
