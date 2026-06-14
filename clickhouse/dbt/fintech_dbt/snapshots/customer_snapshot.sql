{% snapshot customer_snapshot %}


{{ config(
    target_schema='clickhouse',
    unique_key='customer_id',
    strategy='check',
    check_cols=['loyalty_tier']
)}}


select 
    customer_id,
	loyalty_tier,
	country,
	city
    
from {{ source("raw", "customers")}}


{% endsnapshot %}