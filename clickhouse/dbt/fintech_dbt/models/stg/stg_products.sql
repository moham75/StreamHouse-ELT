{{ config(
    materialized='view',
    order_by=['product_id'],
    tags=['scheduled'],
    meta={
        'schedule_unit': 'hour',
        'schedule_every': 1
    }
) }}

select
    product_id,
    category,
    brand,
    price,
    weight_kg
from {{ source('raw', 'products') }}