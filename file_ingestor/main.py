import asyncio

import aiosql

from db import get_conn

queries = aiosql.from_path("./sql/", "asyncpg")  # pyright: ignore[reportUnknownMemberType]

MAX_TASKS = 5


async def main() -> None:
    async with get_conn() as conn:
        async with conn.transaction():
            job = await queries.get_pending_ingestion_job(conn)
            print(job[0])
            await queries.update_job_to_processing(conn, job_id=job[0])


if __name__ == "__main__":
    asyncio.run(main())
