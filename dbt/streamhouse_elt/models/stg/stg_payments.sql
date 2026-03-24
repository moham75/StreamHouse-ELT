SELECT 
    payment_id,
    order_id,
    toDateTime(payment_ts / 1000, 'Asia/Riyadh') AS payment_ts,
    method,
    status,
    amount

FROM {{ source("clickhouse_raw", "payments")}}