defmodule Fauna.HTTP do
  @moduledoc """
  """
  use HTTPoison.Base

  def request(opts, body) do
    case JSX.encode(body) do
      {:ok, json} -> post(url(opts), json, headers(opts))
      res -> res
    end
  end

  def request!(opts, body) do
    case request(opts, body) do
       {:ok, response} -> response
       {:error, error} -> raise error
    end
  end

  defp url(opts) do
    scheme = Keyword.get(opts, :scheme, "https")
    domain = Keyword.get(opts, :domain, "rest.faunadb.com")
    port = Keyword.get(opts, :port, if(scheme == "https", do: 443, else: 80))

    "#{scheme}://#{domain}:#{port}/"
  end

  defp headers(opts) do
    secret = Keyword.get(opts, :secret)
    %{"Authorization": "Basic " <> Base.encode64("#{secret}:")}
  end

  @doc false
  def process_response_body(body) do
    IO.puts "response body #{body}"
    case body |> to_string |> JSX.decode do
      {:error, _} -> body
      {:ok, decoded} -> Fauna.Json.deserialize decoded
    end
  end
end
