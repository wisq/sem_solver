defmodule SemSolver.Word do
  @enforce_keys [:word, :coords]
  defstruct(@enforce_keys)
  alias __MODULE__

  def new(word, coords) do
    %Word{word: word, coords: coords}
  end

  def coordinates(%Word{coords: coords}) do
    parse_coords(coords)
  end

  defp parse_coords(<<>>), do: []
  defp parse_coords(<<c::little-float-32, rest::binary>>), do: [c | parse_coords(rest)]
end

defimpl Inspect, for: SemSolver.Word do
  import Inspect.Algebra

  def inspect(word, opts) do
    concat(["#Word<", to_doc(word.word, opts), ">"])
  end
end
