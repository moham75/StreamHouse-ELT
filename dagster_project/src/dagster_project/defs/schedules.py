import json
import re

import dagster as dg
from dagster_dbt import build_dbt_asset_selection

from dagster_project.defs.dbt_assets import fintech_dbt_assets, DBT_PROJECT_DIR


MANIFEST_PATH = DBT_PROJECT_DIR / "target" / "manifest.json"


def safe_name(name: str) -> str:
    return re.sub(r"[^a-zA-Z0-9_]", "_", name)


def build_cron_from_meta(unit: str, every: int) -> str:
    if unit == "min":
        return f"*/{every} * * * *"

    if unit == "hour":
        return f"0 */{every} * * *"

    raise ValueError(f"Unsupported schedule_unit: {unit}")


def load_scheduled_dbt_models():
    with open(MANIFEST_PATH, "r", encoding="utf-8") as f:
        manifest = json.load(f)

    scheduled_models = []

    for node_id, node in manifest["nodes"].items():
        if node.get("resource_type") != "model":
            continue

        meta = node.get("meta", {})

        schedule_unit = meta.get("schedule_unit")
        schedule_every = meta.get("schedule_every")

        if not schedule_unit or not schedule_every:
            continue

        model_name = node["name"]

        cron_schedule = build_cron_from_meta(
            unit=schedule_unit,
            every=int(schedule_every),
        )

        scheduled_models.append(
            {
                "model_name": model_name,
                "cron_schedule": cron_schedule,
            }
        )

    return scheduled_models


scheduled_models = load_scheduled_dbt_models()

jobs = []
schedules = []

for model in scheduled_models:
    model_name = model["model_name"]
    safe_model_name = safe_name(model_name)

    job = dg.define_asset_job(
        name=f"{safe_model_name}_job",
        selection=build_dbt_asset_selection(
            [fintech_dbt_assets],
            dbt_select=model_name,
        ),
    )

    schedule = dg.ScheduleDefinition(
        name=f"{safe_model_name}_schedule",
        job=job,
        cron_schedule=model["cron_schedule"],
        execution_timezone="Africa/Cairo",
    )

    jobs.append(job)
    schedules.append(schedule)


@dg.definitions
def schedule_defs():
    return dg.Definitions(
        jobs=jobs,
        schedules=schedules,
    )