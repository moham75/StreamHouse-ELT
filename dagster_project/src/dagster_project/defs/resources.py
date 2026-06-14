from pathlib import Path

import dagster as dg
from dagster_dbt import DbtCliResource
from dagster_clickhouse import ClickhouseResource


DBT_PROJECT_DIR = Path("/usr/app/dbt/fintech_dbt")
DBT_PROFILES_DIR = Path("/usr/app/dbt")


@dg.definitions
def resources():
    return dg.Definitions(
        resources={
            "dbt": DbtCliResource(
                project_dir=DBT_PROJECT_DIR,
                profiles_dir=DBT_PROFILES_DIR,
            ),
            "clickhouse": ClickhouseResource(
                host="clickhouse",
                port=9000,
                database="clickhouse",
                user="admin",
                password="admin",
            ),
        }
    )