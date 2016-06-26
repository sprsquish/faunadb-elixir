defmodule Fauna.Json do
  def deserialize(json) do
    case json do
      %{"@ref" => ref}   -> %Fauna.Ref{value: ref}
      %{"@set" => ref}   -> %Fauna.Ref{value: deserialize(ref)}
      %{"@obj" => obj}   -> deserialize(obj)
      %{"@ts" => ts}     -> Time.from_iso8601!(ts)
      %{"@date" => date} -> Time.from_iso8601!(date)
      _ when is_map(json) ->
        json |> Enum.into(%{}, fn {k,v} -> {k, deserialize(v)} end)
      _ when is_list(json) ->
        json |> Enum.map(&deserialize/1)
      _ ->
        json
    end
  end
end
