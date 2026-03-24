SELECT
    a.order_ts AS order_date,
    a.country,
    a.currency,
    a.status AS order_status,
    COUNT(DISTINCT(a.order_id)) AS order_count,
    COUNT(DISTINCT(b.customer_id)) AS customer_count,
    COUNT(DISTINCT(c.merchant_id)) AS merchant_count,
    COUNT(DISTINCT(d.order_item_id)) AS item_count,
    SUM(d.quantity) AS total_quantity,
    {{ gross_item_amount('d.quantity', 'd.unit_price') }} AS gross_item_amount,
    SUM(a.shipping_fee) AS shipping_fee_amount,
    {{ gross_item_amount('d.quantity', 'd.unit_price') }} * SUM(discount_rate) AS discount_amount,
    ( {{ gross_item_amount('d.quantity', 'd.unit_price') }} + SUM(shipping_fee) ) - ( {{ gross_item_amount('d.quantity', 'd.unit_price') }} * SUM(discount_rate) ) AS gmv,
    SUM(e.amount) AS refund_amount

FROM {{ ref("stg_orders") }} a
LEFT JOIN {{ ref("stg_customers") }} b ON a.customer_id = b.customer_id
LEFT JOIN {{ ref("stg_merchants") }} c ON a.merchant_id = c.merchant_id 
LEFT JOIN {{ ref("stg_order_items") }} d ON a.order_id = d.order_id
LEFT JOIN {{ ref("stg_refunds") }} e ON a.order_id = e.order_id

GROUP BY 
    a.order_ts,
    a.country,
    a.currency,
    a.status
