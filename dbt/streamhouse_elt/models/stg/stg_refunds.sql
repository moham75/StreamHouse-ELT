SELECT 
    refund_id,
    order_id,
    toDateTime(refund_ts / 1000, 'Asia/Riyadh') AS refund_ts,
    reason,
    amount

FROM {{ source("clickhouse_raw", "refunds")}}