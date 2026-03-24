SELECT 
    a.order_id,
    a.merchant_id,
    a.order_ts,
    a.status AS order_status,
    a.channel,
    a.country,
    a.currency,
    a.shipping_fee,
    a.discount_rate,
    b.quantity * b.unit_price AS total_price,
    c.status AS payment_status,
    CASE WHEN d.order_id IS NULL THEN 'Not Refunded' ELSE 'Refunded' END AS is_refunded,
    d.amount AS refund_amount


FROM {{ ref("stg_orders") }} a 
LEFT JOIN {{ ref("stg_order_items") }} b ON a.order_id = b.order_id
LEFT JOIN {{ ref("stg_payments") }} c ON a.order_id = c.order_id
LEFT JOIN {{ ref("stg_refunds") }} d ON a.order_id = d.order_id