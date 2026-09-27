defmodule TeacherCoop.FileStore do
  @moduledoc """
  File storage backed by an S3-compatible object store.

  Files never transit through the application: uploads go straight from the
  browser to the bucket through a presigned form (see `create_file/3`, meant
  for LiveView external uploads), and downloads are served through presigned
  URLs (see `get_file_url/2`).

  ## Configuration

  The store is configured under the `TeacherCoop.FileStore` key:

      config :teacher_coop, TeacherCoop.FileStore,
        endpoint: "http://localhost:9090",
        access_key_id: "accesskey",
        secret_access_key: "secret",
        bucket: "teachercoop",
        region: "fr-par"

  In development this points to a local adobe/S3mock instance ran by docker; in production the
  credentials are read from Docker secrets in `config/runtime.exs`.
  """

  alias TeacherCoop.SimpleS3Upload, as: S3Upload
  alias TeacherCoop.SimpleS3Download, as: S3Download

  @doc """
  Create metadata to be used by Phoenix Liviewer external uploader.

  It takes a filename, fileprefix and opts.

  ## Options

    * `:key` - The required key of the object to be uploaded.
    * `:max_file_size` - The required maximum allowed file size in bytes.
    * `:content_type` - The required MIME type of the file to be uploaded.
    * `:expires_in` - The required expiration time in milliseconds from now
      before the signed upload expires.

  Returns a `{:ok, map()}` with metadata.

  """
  @spec create_file(String.t(), String.t(), keyword()) :: {:ok, map()}
  def create_file(filename, fileprefix, opts) do
    %{
      endpoint: endpoint,
      bucket: bucket,
      access_key_id: access_key_id,
      secret_access_key: secret_access_key,
      region: region
    } = config()

    s3_config = %{
      region: region,
      access_key_id: access_key_id,
      secret_access_key: secret_access_key
    }

    key = Path.join([fileprefix, filename])
    opts = Keyword.put(opts, :key, key)
    {:ok, fields} = S3Upload.sign_form_upload(s3_config, bucket, opts)

    meta = %{
      uploader: "S3",
      key: key,
      url: endpoint <> "/#{bucket}",
      fields: fields
    }

    {:ok, meta}
  end

  @doc """
  Create a presigned URL to download the file stored at `key`.

  ## Options

    * `:expires_in` - The expiration time in seconds from now before the signed
      URL expires. Defaults to 3600, maximum is 604800 (7 days).

  Returns the URL as a string.
  """
  @spec get_file_url(String.t(), keyword()) :: String.t()
  def get_file_url(key, opts \\ []) do
    %{endpoint: endpoint, bucket: bucket} = config = config()
    s3_config = Map.take(config, [:region, :access_key_id, :secret_access_key])

    S3Download.sign_download_url(s3_config, endpoint, bucket, key, opts)
  end

  defp config() do
    Application.get_env(:teacher_coop, TeacherCoop.FileStore) |> Map.new()
  end
end
