{{
    config(
        materialized='incremental'
    )
}}
select
    {{ dbt_utils.surrogate_key(["product_line"]) }} as product_line_id,
    product_line,
    '{{ var("current_date") }}'::date as run_date,
    now() as inserted_at
from {{ ref('sales_stg') }} as tab
where tran_datetime::date = '{{ var("current_date") }}'::date
{% if is_incremental() %}
    and tab.product_line not in (select product_line from {{ this }})
{% endif %}
group by
    1, 2
