SELECT 
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    is_promo

FROM {{ source("clickhouse_raw", "order_items")}}