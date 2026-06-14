{{ config(
    materialized='view',
    order_by=["refund_id", "order_id"],
    tags=['scheduled'],
    meta={
        'schedule_unit': 'hour',
        'schedule_every': 1
    }
) }}

select
    refund_id,
    order_id,
    refund_ts,
    reason,
    amount,
    toDateTime(refund_ts / 1000) as refund_datetime,
    toDate(toDateTime(refund_ts / 1000)) as refund_date
from {{ source('raw', 'refunds') }}