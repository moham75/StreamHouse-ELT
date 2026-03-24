SELECT 
    payment_id,
    order_id,
<<<<<<< HEAD
    toDateTime(payment_ts / 1000, 'Asia/Riyadh') AS payment_ts,
=======
    payment_ts,
>>>>>>> cad03e8cee0ebbc88376f7760eafe6794f1cc23d
    method,
    status,
    amount

FROM {{ source("clickhouse_raw", "payments")}}