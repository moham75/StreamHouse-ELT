CREATE DATABASE IF NOT EXISTS clickhouse;

-- customers
CREATE TABLE IF NOT EXISTS clickhouse.customers
(
    customer_id UInt64,
    country String,
    city String,
    signup_ts Int64,
    is_business UInt8,
    loyalty_tier Nullable(String)
)
ENGINE = MergeTree
ORDER BY customer_id
SETTINGS allow_nullable_key = 1;


-- merchants
CREATE TABLE IF NOT EXISTS clickhouse.merchants
(
    merchant_id UInt64,
    country String,
    city Nullable(String),
    category String,
    onboard_ts Nullable(Int64),
    risk_band Nullable(String)
)
ENGINE = MergeTree
ORDER BY merchant_id
SETTINGS allow_nullable_key = 1;


-- products
CREATE TABLE IF NOT EXISTS clickhouse.products
(
    product_id UInt64,
    category Nullable(String),
    brand Nullable(String),
    price Decimal(18, 2),
    weight_kg Decimal(18, 2)
)
ENGINE = MergeTree
ORDER BY (product_id)
SETTINGS allow_nullable_key = 1;


-- orders
CREATE TABLE IF NOT EXISTS clickhouse.orders
(
    order_id UInt64,
    customer_id Nullable(UInt64),
    merchant_id Nullable(UInt64),
    order_ts Int64,
    status Nullable(String),
    channel Nullable(String),
    country Nullable(String),
    currency Nullable(String),
    shipping_fee Decimal(18, 2),
    discount_rate Decimal(18, 4)
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(toDateTime(order_ts / 1000))
ORDER BY (order_ts, order_id)
SETTINGS allow_nullable_key = 1;


-- order_items
CREATE TABLE IF NOT EXISTS clickhouse.order_items
(
    order_item_id UInt64,
    order_id Nullable(UInt64),
    product_id Nullable(UInt64),
    quantity UInt32,
    unit_price Decimal(18, 2),
    is_promo UInt32
)
ENGINE = MergeTree
ORDER BY (order_id, order_item_id)
SETTINGS allow_nullable_key = 1;


-- payments
CREATE TABLE IF NOT EXISTS clickhouse.payments
(
    payment_id UInt64,
    order_id Nullable(UInt64),
    payment_ts Int64,
    method Nullable(String),
    status Nullable(String),
    amount Decimal(18, 2)
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(toDateTime(payment_ts / 1000))
ORDER BY (payment_ts, payment_id)
SETTINGS allow_nullable_key = 1;


-- refunds
CREATE TABLE IF NOT EXISTS clickhouse.refunds
(
    refund_id UInt64,
    order_id Nullable(UInt64),
    refund_ts Int64,
    reason Nullable(String),
    amount Decimal(18, 2)
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(toDateTime(refund_ts / 1000))
ORDER BY (refund_ts, refund_id)
SETTINGS allow_nullable_key = 1;


-- events
CREATE TABLE IF NOT EXISTS clickhouse.events
(
    event_id UInt64,
    customer_id Nullable(UInt64),
    event_ts Int64,
    channel Nullable(String),
    event_type Nullable(String),
    product_id Nullable(UInt64),
    device_os Nullable(String),
    search_query Nullable(String)
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(toDateTime(event_ts / 1000))
ORDER BY (event_ts, event_id)
SETTINGS allow_nullable_key = 1;