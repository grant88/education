{{
    config(
        materialized='incremental'
    )
}}
select
    {{ dbt_utils.surrogate_key(["branch", "city"]) }} as supercenter_id,
    branch,
    city,
    '{{ var("current_date") }}'::date as run_date,
    now() as inserted_at
from {{ ref('sales_stg') }} as tab
where tran_datetime::date = '{{ var("current_date") }}'::date
{% if is_incremental() %}
    and {{ dbt_utils.surrogate_key(["tab.branch", "tab.city"]) }} not in (select supercenter_id from {{ this }})
{% endif %}
group by
    1, 2, 3
