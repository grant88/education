{{
    config(
        materialized='table'
    )
}}
select 
    customer_type
from {{ source('supermarket_sales', 'sales') }}
group by 
    customer_type