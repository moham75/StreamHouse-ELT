SELECT 
    merchant_id,
    country,
    city,
    category,
    onboard_ts,
    risk_band

FROM {{ source("clickhouse_raw", "merchants")}}