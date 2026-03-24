SELECT 
    event_id,
    customer_id,
    product_id,
    toDateTime(event_ts / 1000, 'Asia/Riyadh') AS event_ts,
    channel,
    event_type,
    device_os,
    search_query

FROM {{ source("clickhouse_raw", "events")}}