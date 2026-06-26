defmodule TeacherCoop.Meilisearch do
  @indexes ["documents"]

  def get_client() do
    # Create a Meilisearch client whenever and wherever you need it.
    [endpoint: "http://127.0.0.1:7700", key: "masterkey", finch: :finch_meilisearch]
    |> Meilisearch.Client.new()
  end

  def drop_all() do
    client = get_client()

    tasks =
      @indexes
      |> Enum.map(&{&1, Meilisearch.Index.get(client, &1)})
      |> Enum.reject(&(elem(elem(&1, 1), 0) == :error))
      |> Enum.map(&elem(&1, 0))
      |> Enum.map(&Meilisearch.Index.delete(client, &1))
      |> Enum.map(&elem(&1, 1))

    :ok = wait_for_tasks(tasks)
  end

  def create_indexes() do
    client = get_client()

    {:ok, task} = Meilisearch.Index.create(client, %{uid: "documents", primaryKey: "id"})
    :ok = wait_for_tasks([task])
    IO.puts("     Index 'documents' created")
  end

  defp wait_for_tasks(tasks) when tasks == [] do
    :ok
  end

  defp wait_for_tasks(tasks) do
    result =
      tasks
      |> Enum.map(&wait_for_task(&1))
      |> Enum.all?(fn status -> status in [:succeeded] end)

    if result == true, do: :ok, else: :error
  end

  defp wait_for_task(task) do
    {:ok, task_details} = Meilisearch.Task.get(get_client(), task.taskUid)
    status = Map.get(task_details, :status)

    if status in [:enqueud, :processing] do
      Process.sleep(1000)
      wait_for_task(task)
    else
      status
    end
  end
end

Finch.start_link(name: :finch_meilisearch)

IO.puts("Starting meilisearch operations for reset")
TeacherCoop.Meilisearch.drop_all()
IO.puts(" 1. Dropped all index")
TeacherCoop.Meilisearch.create_indexes()
IO.puts(" 2. Recreated index")
IO.puts("Meilisearch end of operations")
