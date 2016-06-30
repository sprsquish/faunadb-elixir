defmodule Fauna.Ref do
  defstruct value: nil
end

defimpl JSX.Encoder, for: Fauna.Ref do
  def json(ref) do
    [:start_object, "@ref", ref.value, :end_object]
  end
end

defmodule Fauna.SetRef do
  defstruct value: nil
end

defimpl JSX.Encoder, for: Fauna.SetRef do
  def json(ref) do
    [:start_object, "@set", ref.value, :end_object]
  end
end
