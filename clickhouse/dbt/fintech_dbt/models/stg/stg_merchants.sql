{{ config(
    materialized='view',
    order_by=['merchant_id'],
    tags=['scheduled'],
    meta={
        'schedule_unit': 'hour',
        'schedule_every': 1
    }
) }}

select
    merchant_id,
    a.country,
    b.country_name,
    city,
    category,
    toDateTime(onboard_ts / 1000) as onboard_datetime,
    toDate(toDateTime(onboard_ts / 1000)) as onboard_date,
    risk_band 
from {{ source('raw', 'merchants') }} a
LEFT JOIN {{ ref('country_mapping')}} b ON a.country = b.country_code
