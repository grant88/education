{{
    config(
        materialized='table'
    )
}}
select 
    branch,
    city
from {{ source('supermarket_sales', 'sales') }}
group by 
    branch,
    city