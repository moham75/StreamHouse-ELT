{% snapshot merchant_snapshot %}

{{ config(
        target_schema='clickhouse',
        unique_key=['merchant_id'],
        strategy='check',
        check_cols=['risk_band']
)}}

select 
        merchant_id,
        risk_band
from {{ source("raw", "merchants")}}

{% endsnapshot %}