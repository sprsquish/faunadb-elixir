defmodule Fauna.Json do
  def deserialize(json) do
    case json do
      %{"@ref" => ref} ->
        %Fauna.Ref{value: ref}

      %{"@set" => ref} ->
        %Fauna.SetRef{value: deserialize(ref)}

      %{"@obj" => obj} ->
        deserialize(obj)

      %{"@ts" => ts} ->
        {:ok, ndt, _} = Calendar.NaiveDateTime.Parse.iso8601(ts)
        ndt

      %{"@date" => date}  ->
        {:ok, cd} = Calendar.Date.Parse.iso8601(date)
        cd

      _ when is_map(json) ->
        json |> Enum.into(%{}, fn {k,v} -> {k, deserialize(v)} end)

      _ when is_list(json) ->
        json |> Enum.map(&deserialize/1)

      _ ->
        json
    end
  end
end
