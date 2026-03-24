SELECT
    event_id,
    customer_id,
    event_ts,
    channel,
    event_type,
    product_id,
    device_os,
    search_query
    
FROM {{ ref("stg_events")}}