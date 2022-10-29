{{
    config(
        materialized='table'
    )
}}
select 
    gender
from {{ source('supermarket_sales', 'sales') }}
group by 
    gender