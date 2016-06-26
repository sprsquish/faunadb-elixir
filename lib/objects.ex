defmodule Fauna.Ref do
  defstruct value: nil
end

defimpl JSX.Encoder, for: Fauna.Ref do
  def json(ref) do
    ["@ref": ref.value]
  end
end

defmodule Fauna.SetRef do
  defstruct value: nil
end

defimpl JSX.Encoder, for: Fauna.SetRef do
  def json(ref) do
    ["@ref": ref.value]
  end
end
