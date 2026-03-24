SELECT 
    merchant_id,
    country,
    city,
    category,
<<<<<<< HEAD
    toDateTime(onboard_ts / 1000, 'Asia/Riyadh') AS onboard_ts,
=======
    onboard_ts,
>>>>>>> cad03e8cee0ebbc88376f7760eafe6794f1cc23d
    risk_band

FROM {{ source("clickhouse_raw", "merchants")}}