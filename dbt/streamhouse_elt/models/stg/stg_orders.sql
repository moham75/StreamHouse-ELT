SELECT 
    order_id,
    customer_id,
    merchant_id,
    toDateTime(order_ts / 1000, 'Asia/Riyadh') AS order_ts,
    status,
    channel,
    country,
    currency,
    shipping_fee,
    discount_rate

FROM {{ source('clickhouse_raw', 'orders') }}