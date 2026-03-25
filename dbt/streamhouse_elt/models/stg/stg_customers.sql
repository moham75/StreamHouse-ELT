SELECT 
    customer_id,
    country,
    city,
    toDateTime(signup_ts / 1000, 'Asia/Riyadh') AS signup_ts,
    is_business,
    loyalty_tier

FROM {{ source('clickhouse_raw', 'customers') }}