import os
from collections.abc import AsyncGenerator
from contextlib import asynccontextmanager

import asyncpg
from dotenv import load_dotenv

_ = load_dotenv("../.env")

user: str = os.getenv("PG_USER", "")
password: str = os.getenv("PG_PASS", "")
host: str = os.getenv("PG_HOST", "localhost")
port: int = int(os.getenv("PG_PORT", "5432"))
database: str = os.getenv("PG_DB", "")


@asynccontextmanager
async def get_conn() -> AsyncGenerator[asyncpg.pool.PoolConnectionProxy, None]:
    async with asyncpg.create_pool(  # pyright: ignore[reportUnknownMemberType]
        user=user,
        password=password,
        database=database,
        host=host,
        port=port,
        command_timeout=60,
    ) as pool:
        async with pool.acquire() as conn:  # pyright: ignore[reportUnknownVariableType, reportUnknownMemberType]
            yield conn
