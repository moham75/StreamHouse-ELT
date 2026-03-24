SELECT 
    merchant_id,
    country,
    city,
    category,
    toDateTime(onboard_ts / 1000, 'Asia/Riyadh') AS onboard_ts,
    risk_band

FROM {{ source("clickhouse_raw", "merchants")}}