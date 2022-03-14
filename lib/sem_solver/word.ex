defmodule SemSolver.Word do
  @enforce_keys [:word, :coords]
  defstruct(@enforce_keys)
  alias __MODULE__

  def parse(line) do
    [word, coords] = line |> String.split(" ", parts: 2)
    %Word{word: word, coords: coords}
  end

  def coordinates(%Word{coords: coords}) do
    coords
    |> String.trim_trailing()
    |> String.split(" ")
    |> Enum.map(&String.to_float/1)
  end
end

defimpl Inspect, for: SemSolver.Word do
  import Inspect.Algebra

  def inspect(word, opts) do
    concat(["#Word<", to_doc(word.word, opts), ">"])
  end
end
