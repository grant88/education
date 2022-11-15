{{
    config(
        materialized='incremental'
    )
}}
select
    {{ dbt_utils.surrogate_key(["gender"]) }} as gender_id,
    gender,
    '{{ var("current_date") }}' as run_date,
    now() as inserted_at
from {{ ref('sales_stg') }} as tab
where tran_datetime::date = '{{ var("current_date") }}'
{% if is_incremental() %}
    and {{ dbt_utils.surrogate_key(["tab.gender"]) }} not in (select gender_id from {{ this }})
{% endif %}
group by
    1, 2
