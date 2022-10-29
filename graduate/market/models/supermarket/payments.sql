{{
    config(
        materialized='table'
    )
}}
select 
    payment
from {{ source('supermarket_sales', 'sales') }}
group by 
    payment