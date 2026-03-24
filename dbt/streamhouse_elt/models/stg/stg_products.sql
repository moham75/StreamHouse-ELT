SELECT
    product_id,
    category,
    brand,
    price,
    weight_kg

FROM {{ source("clickhouse_raw", "products") }}