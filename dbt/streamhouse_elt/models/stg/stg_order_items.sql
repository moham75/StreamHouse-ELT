SELECT 
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    is_promo

<<<<<<< HEAD
FROM {{ source("clickhouse_raw", "order_items")}}
=======
FROM source{{ ("clickhouse_raw", "order_items")}}
>>>>>>> cad03e8cee0ebbc88376f7760eafe6794f1cc23d
