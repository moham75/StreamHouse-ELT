Synthetic Commerce + Events Dataset (for Postgres -> Kafka -> ClickHouse -> dbt -> Airflow)

Row counts:
- customers: 100,000
- merchants: 20,000
- products: 10,000
- orders: 500,000
- order_items: 1,200,000
- payments: 520,000
- refunds: 30,000
- events: 800,000

Time range: 2024-01-01 to 2026-03-01 (UTC timestamps in ISO string).

Load order (recommended):
1) customers, merchants, products
2) orders
3) order_items
4) payments, refunds
5) events (often lands directly in ClickHouse as well)

See data_dictionary.csv for column meanings.
