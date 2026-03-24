SELECT 
    product_id,
    category,
    brand,
    price,
    weight_kg,
    price * weight_kg AS price_band

FROM {{ ref("stg_products") }}