SELECT 
    refund_id,
    order_id,
    refund_ts,
    reason,
    amount

FROM {{ ref("stg_refunds")}}