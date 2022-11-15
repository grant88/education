{{
    config(
        materialized='table'
    )
}}
select
    product.product_line,
    sum(total) as total_sum
from {{ ref('sales') }} as tab
left join {{ ref('product_line') }} as product
    on  tab.product_line_id = product.product_line_id
group by
    product.product_line