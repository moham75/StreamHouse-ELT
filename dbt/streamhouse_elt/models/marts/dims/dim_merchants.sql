SELECT 
    merchant_id,
    country,
    city,
    category,
    onboard_ts,
    risk_band        

FROM {{ ref("stg_merchants") }}