SELECT 
    customer_id,
    country,
    city,
    signup_ts,
    is_business,
    loyalty_tier,
    toStartOfMonth(signup_ts) AS cohort_month

FROM {{ ref("stg_customers") }} 