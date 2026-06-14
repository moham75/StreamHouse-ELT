{{ config(
    materialized='view',
    order_by=["payment_id", "order_id"],
    tags=['scheduled'],
    meta={
        'schedule_unit': 'hour',
        'schedule_every': 1
    }
) }}

select
    payment_id,
    order_id,
    payment_ts,
    method,
    INITCAP(COALESCE(b.payment_group, method)) as payment_group,
    status,
    amount,
    toDateTime(payment_ts / 1000) as payment_datetime,
    toDate(toDateTime(payment_ts / 1000)) as payment_date,
    case
        when status = 'completed' then true
        else false
    end as is_successful_payment
from {{ source('raw', 'payments') }} a
left join {{ ref('payment_method_mapping')}} b ON a.method = b.payment_method