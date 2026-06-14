# Fintech StreamHouse ELT

A Docker-based data engineering project that loads large fintech CSV datasets into **PostgreSQL**, streams data through **Kafka**, stores analytical data in **ClickHouse**, transforms it with **dbt**, orchestrates assets with **Dagster**, and monitors Kafka/ClickHouse using **Prometheus** and **Grafana**.

---

## Project Summary

This project demonstrates an end-to-end modern data engineering workflow:

```text
CSV Datasets
    ↓
Python Exporter
    ↓
PostgreSQL
    ↓
Kafka / Kafka Connect
    ↓
ClickHouse
    ↓
dbt Models
    ↓
Dagster Asset Orchestration
    ↓
Grafana Monitoring
```

The goal of the project is to practice large-file ingestion, streaming, analytical modelling, orchestration, and monitoring using a fully containerised local environment.

---

## Tech Stack

| Tool | Role |
|---|---|
| **Python** | Reads CSV datasets and exports them into PostgreSQL |
| **PostgreSQL 16.3** | Raw landing database for fintech source data |
| **Kafka 7.6.1** | Streaming layer between PostgreSQL and ClickHouse |
| **Kafka Connect** | Connector runtime used to move source data into Kafka topics |
| **Debezium PostgreSQL Connector** | Enables PostgreSQL CDC support through Kafka Connect |
| **Kafka UI** | Visual interface for Kafka brokers, topics, consumers, lag, and partitions |
| **ZooKeeper** | Kafka coordination service |
| **ClickHouse 24.8** | Analytical database used for fast queries and reporting |
| **dbt** | Transformation layer for staging, fact, snapshot, and source models |
| **Dagster** | Orchestration tool for assets, schedules, automation, and lineage |
| **Prometheus** | Scrapes Kafka exporter metrics |
| **Kafka Exporter** | Exposes Kafka metrics such as partitions, lag, and topic stats |
| **Grafana 13** | Dashboards for Kafka and ClickHouse monitoring |
| **Docker Compose** | Runs all services locally |

---

## Docker Services

| Service | Image / Build | Port(s) | Purpose |
|---|---|---:|---|
| `warehouse` | `postgres:16.3` | `5432` | PostgreSQL raw landing database |
| `etl` | custom build from `./exporter` | — | Python CSV exporter |
| `zookeeper` | `confluentinc/cp-zookeeper:7.6.1` | internal `2181` | Kafka coordination |
| `kafka_broker` | `confluentinc/cp-kafka:7.6.1` | `9092`, `29092` | Kafka broker |
| `kafka_connect` | custom build from `./kafka` | `8083`, `7071` | Kafka Connect + Debezium + JMX exporter |
| `kafkaui` | `provectuslabs/kafka-ui:latest` | `8090` | Kafka web UI |
| `clickhouse` | `clickhouse/clickhouse-server:24.8` | `9000`, `8123` | Analytical warehouse |
| `dbt` | custom build from `./clickhouse/dbt` | `7070` | dbt container for ClickHouse models |
| `kafka_exporter` | `danielqsj/kafka-exporter:latest` | `9308` | Kafka metrics exporter |
| `prometheus` | `prom/prometheus:v3.12.0` | `9090` | Metrics collection |
| `grafana` | `grafana/grafana:13.0.1-security-01` | `3000` | Monitoring dashboards |
| `dagster` | custom build from `./dagster_project` | `3001` | Dagster UI and orchestration |

---

## Architecture

```text
                     ┌──────────────────────┐
                     │      Dagster         │
                     │  orchestration tool  │
                     └──────────┬───────────┘
                                │
                                ▼
┌──────────────┐     ┌─────────────────┐     ┌──────────────┐
│ CSV Datasets │ ──► │ Python Exporter │ ──► │ PostgreSQL   │
└──────────────┘     └─────────────────┘     └──────┬───────┘
                                                     │
                                                     ▼
                                             ┌──────────────┐
                                             │ Kafka        │
                                             │ streaming    │
                                             └──────┬───────┘
                                                    │
                                                    ▼
                                             ┌──────────────┐
                                             │ ClickHouse   │
                                             │ analytics DB │
                                             └──────┬───────┘
                                                    │
                                                    ▼
                                             ┌──────────────┐
                                             │ dbt          │
                                             │ transforms   │
                                             └──────────────┘

Monitoring:
Kafka ──► Kafka Exporter ──► Prometheus ──► Grafana
ClickHouse ───────────────────────────────► Grafana
```

---

## Project Structure

Based on the project structure shown in the screenshots:

```text
FINTECH/
│
├── clickhouse/
│   ├── init.sql
│   └── dbt/
│       ├── dockerfile.dbt
│       ├── profiles.yml
│       ├── requirements.txt
│       └── fintech_dbt/
│           ├── analyses/
│           ├── dbt_packages/
│           ├── logs/
│           ├── macros/
│           ├── models/
│           │   ├── fcts/
│           │   │   ├── fct_events.sql
│           │   │   ├── fct_orders.sql
│           │   │   ├── fct_payments.sql
│           │   │   └── schema.yml
│           │   └── stg/
│           │       ├── schema.yml
│           │       ├── stg_customers.sql
│           │       ├── stg_events.sql
│           │       ├── stg_merchants.sql
│           │       ├── stg_order_items.sql
│           │       ├── stg_orders.sql
│           │       ├── stg_payments.sql
│           │       ├── stg_products.sql
│           │       └── stg_refunds.sql
│           ├── seeds/
│           ├── snapshots/
│           ├── target/
│           ├── tests/
│           ├── source.yml
│           ├── dbt_project.yml
│           └── README.md
│
├── dagster_project/
│   ├── .dg/
│   ├── src/
│   ├── tests/
│   ├── dockerfile.dagster
│   ├── pyproject.toml
│   ├── uv.lock
│   └── README.md
│
├── exporter/
│   ├── datasets/
│   │   ├── customers.csv
│   │   ├── merchants.csv
│   │   ├── products.csv
│   │   ├── orders.csv
│   │   ├── order_items.csv
│   │   ├── payments.csv
│   │   ├── refunds.csv
│   │   └── events.csv
│   ├── dockerfile.export
│   ├── exporter.py
│   └── requirements.txt
│
├── kafka/
│   ├── connectors/
│   │   ├── clickhouse.json
│   │   ├── postgres_cdc.json
│   │   ├── postgres_customers.json
│   │   ├── postgres_events.json
│   │   ├── postgres_merchants.json
│   │   ├── postgres_products.json
│   │   └── postgres_refunds.json
│   ├── plugins/
│   │   ├── clickhouse-kafka-connect-v1.3.5/
│   │   ├── confluentinc-kafka-connect-jdbc-10.9.2/
│   │   └── debezium-postgres-3.1.2/
│   ├── dockerfile.connect
│   └── logs/
│
├── postgres/
│   └── init.sql
│
├── prometheus/
│   └── prometheus.yml
│
├── .env
└── docker-compose.yml
```

---

## Dataset

The project uses the following fintech-style CSV files:

| File | Purpose |
|---|---|
| `customers.csv` | Customer profile and signup data |
| `merchants.csv` | Merchant onboarding and category data |
| `products.csv` | Product reference data |
| `orders.csv` | Order-level transactional data |
| `order_items.csv` | Line-item order details |
| `payments.csv` | Payment attempts and payment status |
| `refunds.csv` | Refund transactions |
| `events.csv` | Customer behavioural / event data |

---

## Python Exporter

The Python exporter loads all CSV datasets into PostgreSQL.

Main actions performed by the exporter:

1. Reads CSV files from `exporter/datasets/`
2. Converts timestamp columns into proper datetime values
3. Connects to PostgreSQL using SQLAlchemy
4. Appends each dataset into its matching PostgreSQL table

Tables loaded into PostgreSQL:

```text
events
customers
merchants
products
orders
order_items
payments
refunds
```

Timestamp conversions performed:

```text
customers.signup_ts
merchants.onboard_ts
orders.order_ts
payments.payment_ts
refunds.refund_ts
events.event_ts
```

---

## PostgreSQL

PostgreSQL is used as the raw operational landing database.

Important configuration:

```yaml
command:
  - "postgres"
  - "-c"
  - "wal_level=logical"
```

This enables logical replication, which is required for CDC-style streaming with Debezium/Kafka Connect.

PostgreSQL responsibilities:

- store raw CSV data
- act as the source system for Kafka Connect
- provide relational tables for customers, orders, payments, refunds, products, merchants, and events

---

## Kafka and Kafka Connect

Kafka is used as the streaming layer.

Kafka responsibilities:

- receive records from PostgreSQL through connector configurations
- organise records into topics
- expose topic, partition, broker, and consumer information through Kafka UI
- provide data movement between PostgreSQL and ClickHouse

Kafka Connect responsibilities:

- run the connector framework
- load the Debezium PostgreSQL connector
- use JSON converters with schemas disabled
- expose JMX metrics on port `7071`

Kafka Connect image is customised using:

```dockerfile
FROM confluentinc/cp-kafka-connect:7.6.1

USER root

RUN confluent-hub install --no-prompt debezium/debezium-connector-postgresql:2.5.4

ENV CONNECT_PLUGIN_PATH="/usr/share/java,/usr/share/confluent-hub-components,/opt/connect-plugins"

USER appuser
```

Kafka UI was used to validate:

- broker status
- broker count
- online partitions
- consumer groups
- assigned topics
- assigned partitions
- consumer lag
- topic list

Observed Kafka UI result from the screenshots:

```text
Consumer group state: STABLE
Assigned topics: 8
Assigned partitions: 17
Total lag: 0
```

---

## ClickHouse

ClickHouse is the analytical warehouse.

ClickHouse responsibilities:

- receive data from Kafka
- store raw analytical tables
- serve dbt transformations
- support Grafana dashboards
- provide fast analytics over orders, payments, refunds, events, customers, merchants, and products

ClickHouse runs on:

```text
Native TCP: 9000
HTTP:       8123
```

---

## dbt

dbt is used for transformation inside ClickHouse.

The dbt project is located at:

```text
clickhouse/dbt/fintech_dbt
```

The screenshots show dbt layers including:

```text
stg
fcts
snapshots
seeds
source.yml
schema.yml
```

### Staging Models

Staging models created:

```text
stg_customers
stg_events
stg_merchants
stg_order_items
stg_orders
stg_payments
stg_products
stg_refunds
```

Purpose:

- clean raw data
- standardise fields
- prepare data for fact models
- expose consistent source models for downstream transformations

### Fact Models

Fact models created:

```text
fct_orders
fct_payments
fct_events
```

Purpose:

- create analytical tables from staging models
- model transactional and behavioural activity
- support downstream dashboards and reporting

### Sources, Seeds, and Snapshots

The project includes dbt source definitions, seed/reference data, and snapshots.

Expected raw sources include:

```text
raw.customers
raw.merchants
raw.products
raw.orders
raw.order_items
raw.payments
raw.refunds
raw.events
```

Used concepts:

- **Sources** for raw ClickHouse tables
- **Seeds** for small mapping/reference datasets
- **Snapshots** for slowly changing entities such as customers and merchants

---

## Dagster

Dagster is used as the orchestration layer.

Dagster responsibilities in this project:

- load the dbt project as assets
- show asset catalog
- show asset lineage
- schedule dbt/staging/fact assets
- track materialisation state
- visualise project dependencies

The screenshots show Dagster features used:

- asset catalog
- definitions page
- asset groups
- schedules / automation
- global asset lineage
- dbt assets
- staging assets
- fact assets
- snapshot assets

Visible asset groups include:

```text
customer_snapshot
merchant_snapshot
dbt
default
fcts
stg
```

Visible schedules include:

```text
fct_events_schedule
fct_orders_schedule
fct_payments_schedule
stg_customers_schedule
stg_events_schedule
stg_merchants_schedule
stg_order_items_schedule
stg_orders_schedule
stg_payments_schedule
stg_products_schedule
stg_refunds_schedule
```

Most schedules shown in the screenshots are configured to run every hour.

---

## Prometheus

Prometheus is used to scrape Kafka metrics from `kafka_exporter`.

Configuration:

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "kafka_exporter"
    static_configs:
      - targets: ["kafka_exporter:9308"]
```

Prometheus responsibilities:

- scrape Kafka exporter metrics every 15 seconds
- store Kafka operational metrics
- provide metrics to Grafana dashboards

---

## Grafana

Grafana is used for monitoring dashboards.

Grafana connects to Prometheus and visualises Kafka metrics.

Dashboards created / shown in screenshots include Kafka monitoring panels for:

- consumer lag
- message activity by topic
- number of partitions by topic
- Kafka topic activity over time

Example metrics visualised:

```text
consumer lag
messages per topic
partition count by topic
broker health
topic activity
consumer group status
```

The Kafka dashboard screenshot shows:

- consumer lag dropping to zero
- partition count by topic
- topic lines for orders, order_items, payments, customers, merchants, products, refunds, and events

---

## Ports

| Tool | URL / Port |
|---|---|
| PostgreSQL | `localhost:5432` |
| Kafka broker | `localhost:9092` |
| Kafka Connect REST API | `localhost:8083` |
| Kafka Connect JMX metrics | `localhost:7071` |
| Kafka UI | `http://localhost:8090` |
| ClickHouse HTTP | `http://localhost:8123` |
| ClickHouse TCP | `localhost:9000` |
| dbt container port | `localhost:7070` |
| Prometheus | `http://localhost:9090` |
| Grafana | `http://localhost:3000` |
| Dagster | `http://localhost:3001` |
| Kafka Exporter | `http://localhost:9308` |

---

## How to Run

### 1. Create `.env`

Create a `.env` file in the project root.

Example:

```env
POSTGRES_DB=postgres
POSTGRES_USER=admin
POSTGRES_PASSWORD=admin

CLICKHOUSE_DB=default
CLICKHOUSE_USER=default
CLICKHOUSE_PASSWORD=admin

GF_SECURITY_ADMIN_USER=admin
GF_SECURITY_ADMIN_PASSWORD=admin
```

### 2. Start the infrastructure

```bash
docker compose up -d
```

### 3. Run the Python exporter

```bash
docker compose up etl
```

or:

```bash
docker compose run --rm etl
```

### 4. Check PostgreSQL tables

```bash
docker exec -it postgres psql -U admin -d postgres
```

Example checks:

```sql
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM payments;
SELECT COUNT(*) FROM events;
```

### 5. Register Kafka connectors

Connector JSON files are stored in:

```text
kafka/connectors/
```

Example command pattern:

```bash
curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  --data @kafka/connectors/postgres_cdc.json
```

Register other connector files as needed.

### 6. Open Kafka UI

```text
http://localhost:8090
```

Use Kafka UI to inspect brokers, topics, consumers, partitions, and lag.

### 7. Open ClickHouse

```text
http://localhost:8123
```

or connect using the native port:

```text
localhost:9000
```

### 8. Run dbt

Enter the dbt container:

```bash
docker exec -it dbt bash
```

Run dbt commands:

```bash
dbt debug
dbt run
dbt test
dbt docs generate
```

### 9. Open Dagster

```text
http://localhost:3001
```

Use Dagster to inspect assets, jobs, schedules, lineage, and materialisations.

### 10. Open Prometheus

```text
http://localhost:9090
```

Check that the `kafka_exporter` target is up.

### 11. Open Grafana

```text
http://localhost:3000
```

Use Grafana to visualise Kafka metrics and pipeline health.

---

## Exercises / Tasks Completed

This section documents the practical exercises completed throughout the project.

### 1. Docker Compose Infrastructure

Completed:

- Created a multi-service Docker Compose environment
- Added PostgreSQL, Kafka, ZooKeeper, Kafka Connect, Kafka UI, ClickHouse, dbt, Dagster, Prometheus, Grafana, and Kafka Exporter
- Configured named volumes for Kafka, ZooKeeper, Grafana, and Dagster
- Exposed ports for local development and UI access

Skills practiced:

- service dependencies
- container networking
- environment variables
- persistent volumes
- custom Docker builds

### 2. Python CSV Exporter

Completed:

- Built a Python exporter service
- Loaded fintech CSV files with pandas
- Converted timestamp fields to datetime
- Uploaded all datasets into PostgreSQL using SQLAlchemy

Tables loaded:

```text
customers
merchants
products
orders
order_items
payments
refunds
events
```

Skills practiced:

- pandas CSV ingestion
- SQLAlchemy database connection
- timestamp conversion
- batch loading to PostgreSQL

### 3. PostgreSQL Landing Layer

Completed:

- Created PostgreSQL service
- Mounted `postgres/init.sql`
- Enabled logical WAL using `wal_level=logical`
- Used PostgreSQL as the source database for Kafka streaming

Skills practiced:

- PostgreSQL Docker setup
- raw landing database design
- CDC-ready PostgreSQL configuration

### 4. Kafka and Kafka Connect

Completed:

- Created Kafka broker with ZooKeeper
- Built custom Kafka Connect image
- Installed Debezium PostgreSQL connector
- Mounted connector plugins
- Added Kafka Connect REST API
- Added JMX metrics support on port `7071`
- Created connector JSON files under `kafka/connectors/`

Skills practiced:

- Kafka broker setup
- Kafka Connect setup
- connector plugin management
- Debezium connector installation
- Kafka topic and consumer validation

### 5. Kafka UI Validation

Completed:

- Added Kafka UI
- Checked broker health
- Checked active controller
- Checked online partitions
- Checked consumers
- Checked assigned topics and partitions
- Verified consumer lag

Observed in screenshots:

```text
Consumer group state: STABLE
Assigned topics: 8
Assigned partitions: 17
Total lag: 0
```

Skills practiced:

- Kafka UI navigation
- consumer group monitoring
- topic inspection
- lag validation

### 6. ClickHouse Analytical Layer

Completed:

- Added ClickHouse service
- Mounted `clickhouse/init.sql`
- Exposed HTTP and native ports
- Used ClickHouse as the dbt target database

Skills practiced:

- ClickHouse Docker setup
- analytical database setup
- raw-to-model transformation flow

### 7. dbt Models

Completed:

- Created dbt project inside `clickhouse/dbt/fintech_dbt`
- Created staging models
- Created fact models
- Created source definitions
- Added schema files
- Used dbt assets inside Dagster

Staging models completed:

```text
stg_customers
stg_events
stg_merchants
stg_order_items
stg_orders
stg_payments
stg_products
stg_refunds
```

Fact models completed:

```text
fct_orders
fct_payments
fct_events
```

Skills practiced:

- dbt project structure
- source definitions
- staging layer
- fact modelling
- schema YAML files
- dbt lineage

### 8. Dagster Orchestration

Completed:

- Added Dagster service
- Mounted dbt project into Dagster container
- Loaded dbt assets into Dagster
- Created/visualised asset groups
- Created schedules for staging and fact models
- Viewed global asset lineage

Asset groups shown:

```text
stg
fcts
dbt
customer_snapshot
merchant_snapshot
default
```

Schedules shown:

```text
stg_* schedules
fct_* schedules
```

Skills practiced:

- Dagster project setup
- dbt + Dagster integration
- asset catalog
- automation
- schedules
- global lineage graph

### 9. Prometheus Monitoring

Completed:

- Added Kafka Exporter
- Added Prometheus service
- Configured Prometheus to scrape Kafka Exporter every 15 seconds

Skills practiced:

- Prometheus scrape configuration
- Kafka exporter setup
- metrics collection

### 10. Grafana Dashboards

Completed:

- Added Grafana service
- Connected Grafana to Prometheus
- Built Kafka monitoring dashboard
- Visualised consumer lag
- Visualised partition counts by topic
- Visualised topic activity

Panels shown:

```text
consumer lag
number of partitions by topic
topic activity over time
```

Skills practiced:

- Grafana dashboard creation
- Prometheus data source usage
- Kafka metric visualisation
- operational monitoring

---

## Final Outcome

By the end of the project, the system demonstrates:

- CSV files loaded into PostgreSQL
- PostgreSQL configured for logical replication
- Kafka and Kafka Connect running in Docker
- Kafka topics and consumers visible in Kafka UI
- ClickHouse running as analytical storage
- dbt staging and fact models created
- Dagster showing dbt assets, schedules, and lineage
- Prometheus scraping Kafka metrics
- Grafana visualising Kafka health and pipeline metrics

This project shows a complete local data engineering platform using containerised services and practical tools used in modern data systems.

---

## Future Improvements

Possible improvements:

- add automated connector registration script
- add more dbt tests
- add ClickHouse metrics to Grafana
- add alert rules for high Kafka lag
- add data quality checks in Dagster
- add ingestion audit tables
- add CI checks for dbt models
- add README screenshots under a `docs/` folder

---

## Short Description

**Fintech StreamHouse ELT** is a Docker-based data engineering pipeline that loads CSV files into PostgreSQL, streams data with Kafka, stores analytics in ClickHouse, transforms data using dbt, orchestrates assets with Dagster, and monitors Kafka metrics with Prometheus and Grafana.
