SELECT 
    customer_id,
    country,
    city,
    signup_ts,
    is_business,
    loyalty_tier

FROM {{ source('clickhouse_raw', 'customers') }}