require Fauna

defmodule HttpTest do
  use ExUnit.Case, async: true

  defp env(name) do
    Map.fetch!(System.get_env(), name)
  end

  defp opts() do
    [
      scheme: env("FAUNA_SCHEME"),
      domain: env("FAUNA_DOMAIN"),
      port: env("FAUNA_PORT"),
      secret: env("FAUNA_ROOT_KEY")
    ]
  end

  test "http query" do
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} = Fauna.query(opts(), do: add(1,2,3))
    assert body == %{"resource" => 6}
  end

  test "http query!" do
    %HTTPoison.Response{status_code: 200, body: body} = Fauna.query!(opts(), do: add(1,2,3))
    assert body == %{"resource" => 6}
  end
end
