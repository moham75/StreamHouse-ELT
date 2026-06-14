{{ config(
    materialized='incremental',
    engine='MergeTree()',
    order_by=['payment_id'],
    unique_key='payment_id',
    incremental_strategy='delete+insert',
    allow_nullable_key=true,
    tags=['scheduled'],
    meta={
        'schedule_unit': 'hour',
        'schedule_every': 1
    }
) }}

SELECT
    p.payment_id,
    p.order_id,
    p.payment_datetime,
    p.method,
    p.status,
    p.amount,
    p.is_successful_payment

FROM {{ ref('stg_payments') }} p

{% if is_incremental() %}
 WHERE p.payment_datetime > 
 (
     SELECT max(payment_datetime) FROM {{ this }}
      )
{% endif %}