import asyncio
import signal

import aiosql

from db import get_conn

queries = aiosql.from_path("./sql/", "asyncpg")  # pyright: ignore[reportUnknownMemberType]

MAX_TASKS = 5

running = True


def handle_shutdown(signum: int, frame: object) -> None:
    global running
    running = False


_ = signal.signal(signal.SIGTERM, handle_shutdown)
_ = signal.signal(signal.SIGINT, handle_shutdown)


async def worker():
    async with get_conn() as conn:
        while running:
            async with conn.transaction():
                job = await queries.get_pending_ingestion_job(conn)
                await queries.update_job_to_processing(conn, job_id=job[0])
                print("Processing job: ", job[0])

            asyncio.sleep(2)


async def main() -> None:
    async with asyncio.TaskGroup() as tg:
        tasks = [tg.create_task(worker()) for _ in range(5)]
    for task in tasks:
        print("Task result: ", task.result)


if __name__ == "__main__":
    asyncio.run(main())
