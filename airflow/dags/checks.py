from airflow import DAG
from airflow.operators.python import PythonOperator
from sqlalchemy import create_engine, text
from datetime import datetime, timedelta


db_connection = "postgresql+psycopg2://postgres:postgres@warehouse:5432/postgres"

warehouse_list = [
    "customers",
    "merchants",
    "products",
    "orders",
    "order_items",
    "payments",
    "refunds",
    "events",
]


def check_tables_exist():
    conn = create_engine(db_connection)

    query_tables = text("""
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'public'
    """)

    with conn.connect() as connection:
        result = connection.execute(query_tables)
        tables = result.fetchall()

    existing_tables = [i[0] for i in tables]
    missing_tables = []

    for table in warehouse_list:
        if table in existing_tables:
            print(f"{table} exists")
        else:
            print(f"{table} does not exist")
            missing_tables.append(table)

    if missing_tables:
        raise ValueError(f"Missing tables: {missing_tables}")


def check_tables_have_data():
    conn = create_engine(db_connection)
    empty_tables = []

    with conn.connect() as connection:
        for table in warehouse_list:
            query = text(f"SELECT COUNT(*) FROM {table}")
            result = connection.execute(query)
            row_count = result.scalar()

            print(f"{table} row count = {row_count}")

            if row_count == 0:
                empty_tables.append(table)

    if empty_tables:
        raise ValueError(f"Empty tables: {empty_tables}")


dag = DAG(
    dag_id="checks",
    start_date=datetime(2026, 1, 1),
    schedule="@daily",
    catchup=False,
    default_args={
        "owner": "airflow",
        "retries": 1,
        "retry_delay": timedelta(minutes=5),
    },
    description="runs checks on warehouse tables",
)

check_tables_exist_task = PythonOperator(
    task_id="check_tables_exist",
    python_callable=check_tables_exist,
    dag=dag,
)

check_tables_have_data_task = PythonOperator(
    task_id="check_tables_have_data",
    python_callable=check_tables_have_data,
    dag=dag,
)

check_tables_exist_task >> check_tables_have_data_task