import pandas as pd 
import numpy as np
from sqlalchemy import create_engine

customer_url = "datasets/customers.csv"
merchant_url = "datasets/merchants.csv"
product_url = "datasets/products.csv"
order_url = "datasets/orders.csv"
order_items_url = "datasets/order_items.csv"
payments_url = "datasets/payments.csv"
refunds_url = "datasets/refunds.csv"
events_url = "datasets/events.csv"


customers = pd.read_csv(customer_url)
merchants = pd.read_csv(merchant_url)
products = pd.read_csv(product_url)
orders = pd.read_csv(order_url)
order_items = pd.read_csv(order_items_url)
payments = pd.read_csv(payments_url)
refunds = pd.read_csv(refunds_url)
events = pd.read_csv(events_url)

# converting to datetime
customers["signup_ts"] = pd.to_datetime(customers["signup_ts"])
merchants["onboard_ts"] = pd.to_datetime(merchants["onboard_ts"])
orders["order_ts"] = pd.to_datetime(orders["order_ts"])
payments["payment_ts"] = pd.to_datetime(payments["payment_ts"])
refunds["refund_ts"] = pd.to_datetime(refunds["refund_ts"])
events["event_ts"] = pd.to_datetime(events["event_ts"])


# building the connection and uploading to data to warehouse service 
conn = create_engine("postgresql+psycopg2://postgres:postgres@warehouse:5432/postgres")

customers.to_sql("customers", conn, if_exists="replace", index=False)
merchants.to_sql("merchants", conn, if_exists="replace", index=False)
products.to_sql("products", conn, if_exists="replace", index=False)
orders.to_sql("orders", conn, if_exists="replace", index=False)
order_items.to_sql("order_items", conn, if_exists="replace", index=False)
payments.to_sql("payments", conn, if_exists="replace", index=False)
refunds.to_sql("refunds", conn, if_exists="replace", index=False)
events.to_sql("events", conn, if_exists="replace", index=False)