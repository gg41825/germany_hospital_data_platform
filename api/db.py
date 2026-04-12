from __future__ import annotations

import os
import time
from functools import lru_cache

from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine, URL


def build_postgres_url() -> URL:
    env = {
        "PGHOST": os.getenv("PGHOST", "localhost"),
        "PGPORT": os.getenv("PGPORT", "5432"),
        "PGUSER": os.getenv("PGUSER"),
        "PGPASSWORD": os.getenv("PGPASSWORD"),
        "PGDATABASE": os.getenv("PGDATABASE"),
    }

    missing = [k for k, v in env.items() if not v]
    if missing:
        raise ValueError(f"Missing PostgreSQL environment variables: {', '.join(missing)}")

    return URL.create(
        "postgresql+psycopg",
        username=env["PGUSER"],
        password=env["PGPASSWORD"],
        host=env["PGHOST"],
        port=int(env["PGPORT"]),
        database=env["PGDATABASE"],
        query={
            "sslmode": os.getenv("PGSSLMODE", "require"),
            "connect_timeout": "10",
        },
    )


def create_engine_with_retry(url: URL, retries: int = 5, base_delay: int = 2) -> Engine:
    for attempt in range(retries):
        try:
            engine = create_engine(
                url,
                pool_pre_ping=True,
                pool_recycle=300,
                connect_args={"connect_timeout": 10},
            )

            with engine.connect() as conn:
                conn.execute(text("SELECT 1"))

            return engine

        except Exception as e:
            if attempt == retries - 1:
                raise

            wait = base_delay * (2 ** attempt)
            print(f"[DB RETRY] attempt={attempt+1} failed, retrying in {wait}s... ({e})")
            time.sleep(wait)


@lru_cache(maxsize=1)
def get_engine() -> Engine:
    return create_engine_with_retry(build_postgres_url())