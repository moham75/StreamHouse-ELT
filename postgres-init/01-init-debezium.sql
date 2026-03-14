CREATE ROLE debezium WITH LOGIN PASSWORD 'debezium';
ALTER ROLE debezium WITH REPLICATION;
GRANT CONNECT ON DATABASE postgres TO debezium;

GRANT USAGE ON SCHEMA public TO debezium;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO debezium;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT ON TABLES TO debezium;

CREATE TABLE public.customers (
    customer_id BIGINT PRIMARY KEY,
    country TEXT,
    city TEXT,
    signup_ts TIMESTAMP,
    is_business INTEGER,
    loyalty_tier TEXT
);

CREATE TABLE public.events (
    event_id BIGINT PRIMARY KEY,
    customer_id BIGINT,
    event_type TEXT,
    event_ts TIMESTAMP,
    device_type TEXT,
    source TEXT
);

CREATE TABLE public.merchants (
    merchant_id BIGINT PRIMARY KEY,
    country TEXT,
    city TEXT,
    category TEXT,
    onboard_ts TIMESTAMP,
    risk_band TEXT
);

CREATE TABLE public.order_items (
    order_item_id BIGINT PRIMARY KEY,
    order_id BIGINT,
    product_id BIGINT,
    quantity INTEGER,
    unit_price NUMERIC(12,2),
    is_promo BIGINT
);

CREATE TABLE public.orders (
    order_id BIGINT PRIMARY KEY,
    customer_id BIGINT,
    merchant_id BIGINT,
    order_ts TIMESTAMP,
    status TEXT,
    channel TEXT,
    country TEXT,
    currency TEXT,
    shipping_fee NUMERIC(12,2),
    discount_rate NUMERIC(12,4)
);

CREATE TABLE public.payments (
    payment_id BIGINT PRIMARY KEY,
    order_id BIGINT,
    payment_ts TIMESTAMP,
    method TEXT,
    status TEXT,
    amount NUMERIC(12,2)
);

CREATE TABLE public.products (
    product_id BIGINT PRIMARY KEY,
    category TEXT,
    brand TEXT,
    base_price NUMERIC(12,2),
    weight_kg NUMERIC(12,3)
);

CREATE TABLE public.refunds (
    refund_id BIGINT PRIMARY KEY,
    order_id BIGINT,
    refund_ts TIMESTAMP,
    reason TEXT,
    amount NUMERIC(12,2)
);


CREATE PUBLICATION dbz_publication FOR ALL TABLES;