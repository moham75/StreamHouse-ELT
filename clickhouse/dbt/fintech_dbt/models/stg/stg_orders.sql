{{ config(
    materialized='view',
    order_by=["order_id", "customer_id", "merchant_id"],
    tags=['scheduled'],
    meta={
        'schedule_unit': 'hour',
        'schedule_every': 1
    }
) }}

select
    order_id,
    customer_id,
    merchant_id,
    order_ts,
    status,
    channel,
    country,
    currency,
    shipping_fee,
    discount_rate,
    toDateTime(order_ts / 1000) as order_datetime,
    toDate(toDateTime(order_ts / 1000)) as order_date

from {{ source('raw', 'orders') }}