defmodule TeacherCoop.FileStore do
  alias TeacherCoop.SimpleS3Upload, as: S3
  alias TeacherCoop.SimpleS3Download, as: S3Download

  @moduledoc """
  """
  @doc """
  Get a file from the filestorage system using the adapter set in `config.exs`.
  `filename`: string that contain the file name as defined by the user.
  `prefix`: path to access the file in the filesystem.

  Returns `{:ok, binary}` in case of success and `{:error, reason}` otherwise.
  """
  @spec get_file(String.t(), String.t(), map()) :: String.t()
  def get_file(filename, fileprefix, opts) do
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
    S3Download.sign_download_url(s3_config, endpoint, bucket, key, opts)
  end

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
    {:ok, fields} = S3.sign_form_upload(s3_config, bucket, opts)

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
