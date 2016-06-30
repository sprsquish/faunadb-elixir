defmodule JsonTest do
  use ExUnit.Case, async: true

  defp decode(json) do
    Fauna.Json.deserialize(JSX.decode!(json))
  end

  test "@ref" do
    json = ~s({"@ref": "database/foo"})
    assert decode(json) == %Fauna.Ref{value: "database/foo"}
  end

  test "@set" do
    json = ~s({"@set": "database/foo"})
    assert decode(json) == %Fauna.SetRef{value: "database/foo"}
  end

  test "@obj" do
    json = ~s({"@obj": {"foo": "bar"}})
    assert decode(json) == %{"foo" => "bar"}
  end

  test "@ts" do
    ts = "1970-01-01T00:00:00+00:00"
    {:ok, dt, _} = Calendar.NaiveDateTime.Parse.iso8601(ts)
    json = ~s({"@ts": "#{ts}"})
    assert decode(json) == dt
  end

  test "@date" do
    date = "1970-01-01"
    {:ok, dt} = Calendar.Date.Parse.iso8601(date)
    json = ~s({"@date": "#{date}"})
    assert decode(json) == dt
  end

  test "nested map" do
    json = ~s({"foo": {"@ref": "bar"}})
    assert decode(json) == %{"foo" => %Fauna.Ref{value: "bar"}}
  end

  test "nested list" do
    json = ~s([{"@ref": "foo"}, {"@ref": "bar"}])
    assert decode(json) == [%Fauna.Ref{value: "foo"}, %Fauna.Ref{value: "bar"}]
  end
end
