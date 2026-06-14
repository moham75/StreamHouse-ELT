from pathlib import Path

import dagster as dg
from dagster_dbt import DbtCliResource, DagsterDbtTranslator, dbt_assets


DBT_PROJECT_DIR = Path("/usr/app/dbt/fintech_dbt")


class CustomDagsterDbtTranslator(DagsterDbtTranslator):
    def get_group_name(self, dbt_resource_props):

        fqn = dbt_resource_props.get("fqn", [])

        if len(fqn) >= 3:
            return fqn[1]  

        return "dbt"


@dbt_assets(
    manifest=DBT_PROJECT_DIR / "target" / "manifest.json",
    dagster_dbt_translator=CustomDagsterDbtTranslator(),
)
def fintech_dbt_assets(context: dg.AssetExecutionContext, dbt: DbtCliResource):
    yield from dbt.cli(["build"], context=context).stream()


@dg.definitions
def dbt_defs():
    return dg.Definitions(
        assets=[fintech_dbt_assets]
    )