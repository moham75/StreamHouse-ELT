{{ config(
    materialized='incremental',
    engine='MergeTree()',
    order_by='event_id',
    unique_key='event_id',
    incremental_strategy='delete+insert',
    tags=['scheduled'],
    meta={
        'schedule_unit': 'hour',
        'schedule_every': 1
    }
) }}

SELECT
    e.event_id,
    e.customer_id,
    e.product_id,
    e.device_os,
    e.search_query,
    e.event_type,
    e.event_datetime

FROM {{ ref('stg_events') }} e

{% if is_incremental() %}
WHERE e.event_datetime > (
    SELECT max(t.event_datetime)
    FROM {{ this }} AS t
)
{% endif %}