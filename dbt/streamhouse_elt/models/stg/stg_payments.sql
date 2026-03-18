SELECT 
    payment_id,
    order_id,
    payment_ts,
    method,
    status,
    amount

FROM {{ source("clickhouse_raw", "payments")}}