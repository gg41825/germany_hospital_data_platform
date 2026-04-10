from __future__ import annotations

import os
from typing import Any

from fastapi import FastAPI, HTTPException, Query
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError

from api.db import get_engine


app = FastAPI(
    title="Germany Hospital Data Platform API",
    description="Curated API layer on top of dbt-built hospital analytics tables.",
    version="0.1.0",
)


def analytics_schema() -> str:
    return os.getenv("DBT_SCHEMA", "analytics")


def run_query(statement: str, params: dict[str, Any] | None = None) -> list[dict[str, Any]]:
    try:
        with get_engine().connect() as connection:
            result = connection.execute(text(statement), params or {})
            return [dict(row) for row in result.mappings().all()]
    except SQLAlchemyError as exc:
        raise HTTPException(status_code=503, detail=f"Database query failed: {exc}") from exc


@app.get("/health")
def healthcheck() -> dict[str, str]:
    run_query("select 1 as ok")
    return {"status": "ok"}


@app.get("/hospitals")
def list_hospitals(
    state_code: str | None = Query(default=None, description="German state code filter."),
    department_name: str | None = Query(
        default=None,
        description="Normalized department name in German.",
    ),
    q: str | None = Query(
        default=None,
        description="Free-text search over hospital name and city.",
    ),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
) -> dict[str, Any]:
    schema = analytics_schema()
    filters = []
    params: dict[str, Any] = {"limit": limit, "offset": offset}

    if state_code:
        filters.append("h.state_code = :state_code")
        params["state_code"] = state_code

    if q:
        filters.append("(h.site_name ilike :search_query or h.city ilike :search_query)")
        params["search_query"] = f"%{q}%"

    if department_name:
        filters.append(
            f"""
            exists (
                select 1
                from {schema}.fct_hospital_department_volume as fdv
                where fdv.site_id = h.site_id
                  and lower(fdv.department_name_de) = lower(:department_name)
            )
            """
        )
        params["department_name"] = department_name

    where_clause = f"where {' and '.join(filters)}" if filters else ""

    rows = run_query(
        f"""
        select
            h.site_id,
            h.site_name,
            h.state_code,
            h.city,
            h.address,
            h.owner_type,
            h.emergency_level,
            h.emergency_level_description,
            h.department_count,
            h.departments,
            h.google_map_url,
            h.website_url,
            h.phone
        from {schema}.mart_hospital_department_summary as h
        {where_clause}
        order by h.department_count desc nulls last, h.site_name
        limit :limit offset :offset
        """,
        params,
    )

    return {
        "data": rows,
        "pagination": {"limit": limit, "offset": offset, "returned_rows": len(rows)},
    }


@app.get("/hospitals/{site_id}")
def get_hospital(site_id: str) -> dict[str, Any]:
    schema = analytics_schema()

    hospital_rows = run_query(
        f"""
        select
            summary.site_id,
            summary.site_name,
            summary.state_code,
            summary.street,
            summary.postal_code,
            summary.city,
            summary.address,
            summary.google_map_url,
            summary.phone,
            summary.website_url,
            summary.email,
            summary.owner_type,
            summary.emergency_level,
            summary.emergency_level_description,
            summary.department_count,
            summary.departments,
            dim.bed_count,
            dim.case_count,
            dim.nurse_count,
            dim.nursing_staff_ratio,
            dim.has_pediatric_clinic,
            dim.has_service_mandate,
            dim.has_trauma_care_module,
            dim.trauma_care_description,
            dim.pediatric_emergency_level,
            dim.pediatric_emergency_description,
            dim.has_special_emergency_care,
            dim.special_emergency_description,
            dim.has_stroke_unit,
            dim.stroke_unit_description,
            dim.has_chest_pain_unit,
            dim.chest_pain_unit_description
        from {schema}.mart_hospital_department_summary as summary
        left join {schema}.dim_hospitals as dim
            on summary.site_id = dim.site_id
        where summary.site_id = :site_id
        """,
        {"site_id": site_id},
    )

    if not hospital_rows:
        raise HTTPException(status_code=404, detail=f"Hospital {site_id} not found")

    department_rows = run_query(
        f"""
        select
            department_id,
            source_department_name,
            department_name_de,
            department_name_en,
            department_name_zh,
            case_count
        from {schema}.fct_hospital_department_volume
        where site_id = :site_id
        order by case_count desc nulls last, department_name_de, source_department_name
        """,
        {"site_id": site_id},
    )

    return {
        "hospital": hospital_rows[0],
        "departments": department_rows,
    }
