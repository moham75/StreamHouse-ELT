{{ config(
    materialized='view',
    order_by=["order_item_id", "order_id", "product_id"],
    tags=['scheduled'],
    meta={
        'schedule_unit': 'hour',
        'schedule_every': 1
    }
) }}

select
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    is_promo,
    quantity * unit_price as line_amount
from {{ source('raw', 'order_items') }}