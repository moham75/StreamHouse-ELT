{{ config(
    materialized='view',
    order_by=["customer_id"],
    tags=['scheduled'],
    meta={
        'schedule_unit': 'hour',
        'schedule_every': 1
    }
) }}

SELECT 
    a.customer_id,
    a.country,
    b.country_name,
    b.region,
    a.city,
    a.is_business,
    a.loyalty_tier,
    toDateTime(a.signup_ts / 1000) as signup_datetime,
    toDate(toDateTime(a.signup_ts / 1000)) as signup_date

FROM {{ source("raw", "customers") }} a
LEFT JOIN {{ ref('country_mapping')}} b ON a.country = b.country_code
