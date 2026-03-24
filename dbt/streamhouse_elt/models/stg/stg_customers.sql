SELECT 
    customer_id,
    country,
    city,
<<<<<<< HEAD
    toDateTime(signup_ts / 1000, 'Asia/Riyadh') AS signup_ts,
=======
    signup_ts,
>>>>>>> cad03e8cee0ebbc88376f7760eafe6794f1cc23d
    is_business,
    loyalty_tier

FROM {{ source('clickhouse_raw', 'customers') }}