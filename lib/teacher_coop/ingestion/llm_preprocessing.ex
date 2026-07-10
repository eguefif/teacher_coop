defmodule TeacherCoop.Ingestion.LLMPreprocessing do
  @url "http://localhost:11434/api/generate"
  @model "qcwind/qwen3-8b-instruct-Q4-K-M:latest"
  # @model "qwen3.5:2b"

  def preprocess(document) do
    payload = build_payload(document)
    request = Finch.build(:post, @url, [], payload)

    {:ok, response} =
      Finch.request(request, :llm_finch, receive_timeout: :infinity, request_timeout: :infinity)

    IO.inspect(response)

    if response.status == 200 do
      body = Jason.decode!(response.body)
      body.response
    else
      ""
    end
  end

  def build_payload(document) do
    Jason.encode!(%{
      "model" => @model,
      "prompt" => build_prompt(document),
      "think" => false,
      "raw" => true
    })
  end

  def build_prompt(document) do
    ~s"""
     Tu es un enseignant dont le travail consiste à analyser des documents, écrire un résumé permettant à d'autres enseignants de retrouver le document facilement via une recherche sémantique.

     Voici ce document qui a été extrait d'un PDF:
     #{document}

     Je veux que tu écrives un résumé. Je voudrais aussi une liste de phrases qui décrivent certains aspect du documents. Je veux que tu écrives le tout sous la forme d'un fichier texte qui pourra être transformer en embeddings facilement.
    """
  end
end
