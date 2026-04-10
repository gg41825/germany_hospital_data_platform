from __future__ import annotations

import os
from functools import lru_cache

from sqlalchemy import create_engine
from sqlalchemy.engine import Engine, URL


def build_postgres_url() -> URL:
    env = {
        "PGHOST": os.getenv("PGHOST", "localhost"),
        "PGPORT": os.getenv("PGPORT", "5432"),
        "PGUSER": os.getenv("PGUSER"),
        "PGPASSWORD": os.getenv("PGPASSWORD"),
        "PGDATABASE": os.getenv("PGDATABASE"),
    }
    missing = [key for key, value in env.items() if not value]
    if missing:
        raise ValueError(
            "Missing PostgreSQL environment variables: " + ", ".join(sorted(missing))
        )

    return URL.create(
        "postgresql+psycopg",
        username=env["PGUSER"],
        password=env["PGPASSWORD"],
        host=env["PGHOST"],
        port=int(env["PGPORT"]),
        database=env["PGDATABASE"],
        query={"sslmode": os.getenv("PGSSLMODE", "prefer")},
    )


@lru_cache(maxsize=1)
def get_engine() -> Engine:
    return create_engine(build_postgres_url(), pool_pre_ping=True)

