# Germany Hospital Data Platform

This project transforms Bundes-Klinik-Atlas open data into an analysis-ready data platform for exploring hospitals in Germany.

Inspired by a friend who recently needed emergency hospital care in Germany, this project started from a very practical question: as a foreigner, how do you quickly find the right hospital and understand what it can actually treat?

It enables users to discover hospitals by state, department, and treatment volume, and to compare hospital capabilities such as emergency care and specialized services.

## Use Case
Help users answer practical questions such as:
- Which hospitals in a given state offer a specific department?
- Which hospital should I look at for a certain treatment area?
- Does a hospital have emergency, pediatric emergency, stroke-unit, or trauma-care capabilities?
---
## Architecture
Data Source: [Bundes-Klinik-Atlas open data](https://bundes-klinik-atlas.de/open-data/)

```text
Bundes-Klinik-Atlas XML
    |
    v
Ingestion (Python)
    |
    v
Postgres
  raw schema / landing tables
    |
    v
dbt transformation on Postgres
  staging / marts / tests
    |
    v
analytics-ready warehouse tables
    |
    +--> Metabase
    +--> FastAPI
    +--> Analytics
```
---
## Tech Stack
- PostgreSQL (Neon) for data storage
- dbt for transformation and testing
- Python for ingestion
- Metabase for dashboards
- FastAPI for application and API serving
- GitHub Actions for CI
---
## Data Model
### Core Tables
- `dim_hospitals`  
  Hospital-level attributes (location, ownership, capacity, emergency care)

- `dim_department`  
  Normalized medical departments (DE / EN / ZH)

- `fct_hospital_department_volume`  
  Case volume by hospital and department

- `fct_hospital_disease_volume`  
  Case volume by disease or procedure

- `mart_hospital_department_summary`  
  One row per hospital for dashboard listing
---
## Quick Start

### 1. Setup Python Environment

```bash
python3 -m venv venv
source venv/bin/activate  # macOS / Linux
# venv\Scripts\activate   # Windows

pip install --upgrade pip
pip install -r ingestion/requirements.txt
pip install -r api/requirements.txt
```

### 2. Set Environment Variables

```bash
export PGHOST=localhost
export PGPORT=5432
export PGUSER=postgres
export PGPASSWORD=postgres
export PGDATABASE=germany_healthcare
export PGSSLMODE=require

export RAW_SCHEMA=raw_bka
export DBT_SCHEMA=analytics
export DBT_PROFILE=germany_hospital_data_platform
export DBT_TARGET=dev
```

### 3. Load Data
```bash
python3 ingestion/load_bka_xml.py ingestion/fixtures/bka_ci_data.xml --raw-schema "${RAW_SCHEMA}"
```

### 4. Run dbt
```bash
cd dbt
dbt build --profiles-dir . --profile "${DBT_PROFILE}" --target "${DBT_TARGET}"
```

### 5. Generate docs
```bash
dbt docs generate --profiles-dir . --profile "${DBT_PROFILE}" --target "${DBT_TARGET}"
```

### 6. Run API
```bash
python -m uvicorn api.main:app --reload --port 8000
```

The API uses the same PostgreSQL environment variables as ingestion and dbt.
Open `http://127.0.0.1:8000/docs` for the interactive API docs.
---
## CI
The repository includes a GitHub Actions workflow for dbt validation.

If enabled, the workflow:
- starts a temporary PostgreSQL instance
- loads fixture data from `ingestion/fixtures/bka_ci_data.xml`
- runs `dbt build`
- generates dbt documentation

This workflow is intended to verify that:
- dbt models build successfully
- data tests pass
- the transformation pipeline remains reproducible in a clean environment
---
## Serving Layer
- Metabase reads analytics tables for dashboards and self-service exploration.
- FastAPI can expose curated hospital and department endpoints backed by dbt marts.
- Analysts can query the same warehouse tables directly from notebooks or SQL clients.
- Current API endpoints include `/health`, `/hospitals`, and `/hospitals/{site_id}`.
---
## Notes on Dashboard Semantics
- `state_code` can be mapped to human-readable names via `state_mapping`
- Department names are standardized via dbt seeds
- Fact tables should be used for filtering; marts are optimized for dashboards
---
## Future Improvements
- Join state names directly into marts so dashboards do not need a separate lookup
- Version control BI dashboards
---
## License / Usage
Built as a portfolio project using publicly available Bundes-Klinik-Atlas data.
