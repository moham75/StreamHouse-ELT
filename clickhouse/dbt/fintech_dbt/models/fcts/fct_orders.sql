{{ config(
    materialized='incremental',
    engine='MergeTree()',
    order_by='o.order_id',
    unique_key='o.order_id',
    incremental_strategy='delete+insert',
    tags=['scheduled'],
    meta={
        'schedule_unit': 'hour',
        'schedule_every': 1
    }
) }}

WITH order_totals AS (

    SELECT
        oi.order_id,
        SUM(toFloat64(oi.quantity) * toFloat64(oi.unit_price)) AS order_gross_amount
    FROM {{ ref('stg_order_items') }} oi
    GROUP BY oi.order_id

),

refunds AS (

    SELECT
        order_id,
        SUM(toFloat64(amount)) AS refund_amount
    FROM {{ ref('stg_refunds') }}
    GROUP BY order_id

),

payments AS (

    SELECT
        order_id,
        max(status) AS status,
        max(is_successful_payment) AS is_successful_payment
    FROM {{ ref('stg_payments') }}
    GROUP BY order_id

)

SELECT
    o.order_id,
    o.customer_id,
    o.merchant_id,
    o.order_datetime,

    ot.order_gross_amount,

    (
        toFloat64(ot.order_gross_amount)
        - toFloat64(coalesce(o.discount_rate, 0))
    ) AS order_net_amount,

    p.status,
    p.is_successful_payment,

    coalesce(r.refund_amount, 0) AS refund_amount,

    CASE
        WHEN (
            toFloat64(ot.order_gross_amount)
            - toFloat64(coalesce(o.discount_rate, 0))
        ) > 0
        THEN
            toFloat64(coalesce(r.refund_amount, 0))
            /
            nullIf(
                toFloat64(ot.order_gross_amount)
                - toFloat64(coalesce(o.discount_rate, 0)),
                0
            )
        ELSE 0
    END AS refund_ratio

FROM {{ ref('stg_orders') }} o
LEFT JOIN order_totals ot
    ON o.order_id = ot.order_id
LEFT JOIN payments p
    ON o.order_id = p.order_id
LEFT JOIN refunds r
    ON o.order_id = r.order_id


{% if is_incremental() %}
 WHERE o.order_datetime > 
 (
     SELECT max(order_datetime) FROM {{ this }}
      )
{% endif %}