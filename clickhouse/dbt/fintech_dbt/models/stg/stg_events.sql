{{ config(
    materialized='view',
    order_by=["event_id", "customer_id"],
    tags=['scheduled'],
    meta={
        'schedule_unit': 'hour',
        'schedule_every': 1
    }
) }}

select
    event_id,
    customer_id,
    event_ts,
    channel,
    event_type,
    product_id,
    device_os,
    search_query,
    toDateTime(event_ts / 1000) as event_datetime,
    toDate(toDateTime(event_ts / 1000)) as event_date
from {{ source('raw', 'events') }}