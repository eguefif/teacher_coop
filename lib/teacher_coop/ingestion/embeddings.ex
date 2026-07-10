defmodule TeacherCoop.Ingestion.Embeddings do
  @embedder_url "http://localhost:8080/embed"

  def embed(documents) when documents == [], do: []

  def embed(documents) when is_list(documents) do
    Enum.chunk_every(documents, 30)
    |> Enum.map(&get_embeddings/1)
  end

  def get_embeddings(docs) do
    payload = build_payload(docs)
    request = Finch.build(:post, @embedder_url, [{"Content-Type", "application/json"}], payload)
    {:ok, result} = Finch.request(request, :embeddings_finch)
    200 = result.status
    Jason.decode!(result.body)
  end

  def build_payload(docs) do
    %{"inputs" => docs}
    |> Jason.encode!()
  end
end
