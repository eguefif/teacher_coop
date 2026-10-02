defmodule TeacherCoop.SimpleS3Download do
  @moduledoc """
  Dependency-free S3 presigned GET URL using query string sigv4

  https://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-query-string-auth.html
  """

  @doc """
  Signs a download URL.

  The configuration is a map which must contain the following keys:

    * `:region` - The AWS region, such as "us-east-1"
    * `:access_key_id` - The AWS access key id
    * `:secret_access_key` - The AWS secret access key

  The endpoint must already address the bucket: either a virtual-hosted URL
  (`https://my-bucket.s3.fr-par.scw.cloud`) or a path-style URL including the
  bucket (`http://localhost:9090/my-bucket`). Its path is prefixed to the key.

  Returns a URL that can be used to GET the object until it expires.

  ## Options

    * `:expires_in` - The expiration time in seconds from now before the signed
      URL expires. Defaults to 3600, maximum is 604800 (7 days).
    * `:datetime` - The signing time. Defaults to `DateTime.utc_now/0`.

  ## Examples

      config = %{
        region: "us-east-1",
        access_key_id: System.fetch_env!("AWS_ACCESS_KEY_ID"),
        secret_access_key: System.fetch_env!("AWS_SECRET_ACCESS_KEY")
      }

      SimpleS3Download.sign_download_url(
        config,
        "https://my-bucket.s3.us-east-1.amazonaws.com",
        "public/my-file-name",
        expires_in: 3600
      )

  """
  def sign_download_url(config, endpoint, key, opts \\ []) do
    expires_in = Keyword.get(opts, :expires_in, 3600)
    datetime = Keyword.get_lazy(opts, :datetime, &DateTime.utc_now/0)

    amz_date = amz_date(datetime)
    uri = URI.parse(endpoint)
    host = if uri.port in [80, 443], do: uri.host, else: "#{uri.host}:#{uri.port}"

    path =
      (uri.path || "") <> "/" <> (key |> String.split("/") |> Enum.map_join("/", &aws_encode/1))

    # Query parameters must be sorted alphabetically
    query =
      [
        {"X-Amz-Algorithm", "AWS4-HMAC-SHA256"},
        {"X-Amz-Credential", credential(config, datetime)},
        {"X-Amz-Date", amz_date},
        {"X-Amz-Expires", Integer.to_string(expires_in)},
        {"X-Amz-SignedHeaders", "host"}
      ]
      |> Enum.map_join("&", fn {name, value} -> "#{name}=#{aws_encode(value)}" end)

    canonical_request =
      Enum.join(["GET", path, query, "host:#{host}", "", "host", "UNSIGNED-PAYLOAD"], "\n")

    string_to_sign =
      Enum.join(
        [
          "AWS4-HMAC-SHA256",
          amz_date,
          "#{short_date(datetime)}/#{config.region}/s3/aws4_request",
          :crypto.hash(:sha256, canonical_request) |> Base.encode16(case: :lower)
        ],
        "\n"
      )

    "#{uri.scheme}://#{host}#{path}?#{query}&X-Amz-Signature=#{signature(config, datetime, string_to_sign)}"
  end

  defp aws_encode(value), do: URI.encode(value, &URI.char_unreserved?/1)

  defp amz_date(time) do
    time
    |> NaiveDateTime.to_iso8601()
    |> String.split(".")
    |> List.first()
    |> String.replace("-", "")
    |> String.replace(":", "")
    |> Kernel.<>("Z")
  end

  defp credential(%{} = config, %DateTime{} = datetime) do
    "#{config.access_key_id}/#{short_date(datetime)}/#{config.region}/s3/aws4_request"
  end

  defp signature(config, %DateTime{} = datetime, string_to_sign) do
    config
    |> signing_key(datetime, "s3")
    |> sha256(string_to_sign)
    |> Base.encode16(case: :lower)
  end

  defp signing_key(%{} = config, %DateTime{} = datetime, service) when service in ["s3"] do
    amz_date = short_date(datetime)
    %{secret_access_key: secret, region: region} = config

    ("AWS4" <> secret)
    |> sha256(amz_date)
    |> sha256(region)
    |> sha256(service)
    |> sha256("aws4_request")
  end

  defp short_date(%DateTime{} = datetime) do
    datetime
    |> amz_date()
    |> String.slice(0..7)
  end

  defp sha256(secret, msg), do: :crypto.mac(:hmac, :sha256, secret, msg)
end
