CREATE DATABASE IF NOT EXISTS clickhouse;

-- customers
CREATE TABLE IF NOT EXISTS clickhouse.customers
(
    customer_id UInt64,
    first_name String,
    last_name String,
    email String,
    phone Nullable(String),
    country String,
    city String,
    signup_ts DateTime,
    is_business UInt8,
    loyalty_tier Nullable(String),
    updated_at Nullable(DateTime)
)
ENGINE = MergeTree
ORDER BY customer_id;


-- merchants
CREATE TABLE IF NOT EXISTS clickhouse.merchants
(
    merchant_id UInt64,
    merchant_name String,
    category Nullable(String),
    country String,
    city Nullable(String),
    created_at Nullable(DateTime),
    updated_at Nullable(DateTime)
)
ENGINE = MergeTree
ORDER BY merchant_id;


-- products
CREATE TABLE IF NOT EXISTS clickhouse.products
(
    product_id UInt64,
    merchant_id UInt64,
    product_name String,
    category Nullable(String),
    brand Nullable(String),
    price Decimal(18, 2),
    currency Nullable(String),
    is_active UInt8,
    created_at Nullable(DateTime),
    updated_at Nullable(DateTime)
)
ENGINE = MergeTree
ORDER BY (merchant_id, product_id);


-- orders
CREATE TABLE IF NOT EXISTS clickhouse.orders
(
    order_id UInt64,
    customer_id UInt64,
    merchant_id UInt64,
    order_ts DateTime,
    order_status String,
    total_amount Decimal(18, 2),
    currency Nullable(String),
    payment_status Nullable(String),
    updated_at Nullable(DateTime)
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(order_ts)
ORDER BY (order_ts, order_id);


-- order_items
CREATE TABLE IF NOT EXISTS clickhouse.order_items
(
    order_item_id UInt64,
    order_id UInt64,
    product_id UInt64,
    quantity UInt32,
    unit_price Decimal(18, 2),
    line_amount Decimal(18, 2),
    created_at Nullable(DateTime)
)
ENGINE = MergeTree
ORDER BY (order_id, order_item_id);


-- payments
CREATE TABLE IF NOT EXISTS clickhouse.payments
(
    payment_id UInt64,
    order_id UInt64,
    customer_id UInt64,
    payment_ts DateTime,
    payment_method Nullable(String),
    payment_status String,
    amount Decimal(18, 2),
    currency Nullable(String),
    provider Nullable(String),
    updated_at Nullable(DateTime)
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(payment_ts)
ORDER BY (payment_ts, payment_id);


-- refunds
CREATE TABLE IF NOT EXISTS clickhouse.refunds
(
    refund_id UInt64,
    payment_id UInt64,
    order_id UInt64,
    refund_ts DateTime,
    refund_reason Nullable(String),
    refund_status Nullable(String),
    amount Decimal(18, 2),
    currency Nullable(String),
    updated_at Nullable(DateTime)
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(refund_ts)
ORDER BY (refund_ts, refund_id);


-- events
CREATE TABLE IF NOT EXISTS clickhouse.events
(
    event_id UInt64,
    customer_id Nullable(UInt64),
    session_id Nullable(String),
    event_name String,
    event_ts DateTime,
    source Nullable(String),
    device Nullable(String),
    country Nullable(String),
    city Nullable(String),
    metadata String
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(event_ts)
ORDER BY (event_ts, event_id);