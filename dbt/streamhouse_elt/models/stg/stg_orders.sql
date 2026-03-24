SELECT 
    order_id,
    customer_id,
    merchant_id,
<<<<<<< HEAD
    toDateTime(order_ts / 1000, 'Asia/Riyadh') AS order_ts,
=======
    order_ts,
>>>>>>> cad03e8cee0ebbc88376f7760eafe6794f1cc23d
    status,
    channel,
    country,
    currency,
    shipping_fee,
    discount_rate

FROM {{ source('clickhouse_raw', 'orders') }}