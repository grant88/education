{{
    config(
        materialized='incremental'
    )
}}
select
    {{ dbt_utils.surrogate_key(["customer_type"]) }} as customer_type_id,
    customer_type,
    '{{ var("current_date") }}' as run_date,
    now() as inserted_at
from {{ ref('sales_stg') }} as tab
where tran_datetime::date = '{{ var("current_date") }}'
{% if is_incremental() %}
    and {{ dbt_utils.surrogate_key(["tab.customer_type"]) }} not in (select customer_type_id from {{ this }})
{% endif %}
group by
    1, 2
