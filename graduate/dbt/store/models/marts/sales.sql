{%- set source_relation = adapter.get_relation(
        database=this.database ,
        schema=this.schema,
        identifier=this.name) -%}
{{
    config(
        materialized='incremental',
        pre_hook=[
            "delete from {{ this }} where tran_datetime::date = '{{ var('current_date') }}'" if source_relation else ""
        ]
    )
}}
select
    id,
    invoice_id,
    tran_datetime,
    {{ dbt_utils.surrogate_key(["product_line"]) }} as product_line_id,
    {{ dbt_utils.surrogate_key(["branch", "city"]) }} as supercenter_id,
    {{ dbt_utils.surrogate_key(["customer_type"]) }} as customer_type_id,
    {{ dbt_utils.surrogate_key(["gender"]) }} as gender_id,
    {{ dbt_utils.surrogate_key(["payment"]) }} as payment_id,
    quantity,
    unit_price,
    tax_5_percent,
    total,
    cogs,
    gross_income
from {{ ref('sales_stg') }} as tab
where tran_datetime::date = '{{ var("current_date") }}'
{% if is_incremental() %}
    and 1=1
{% endif %}