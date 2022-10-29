{{
    config(
        materialized='table'
    )
}}
select 
    product_line
from {{ source('supermarket_sales', 'sales') }}
group by 
    product_line