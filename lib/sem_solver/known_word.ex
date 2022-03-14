defmodule SemSolver.KnownWord do
  @enforce_keys [:word, :coords, :norm]
  defstruct(@enforce_keys)

  alias SemSolver.Word
  alias __MODULE__

  def from_word(%Word{} = word) do
    coords = Word.coordinates(word)

    %KnownWord{
      word: word,
      coords: coords,
      norm: norm(coords)
    }
  end

  def distance(%KnownWord{} = known, %Word{} = other) do
    other_coords = Word.coordinates(other)

    dot_p = dot_product(known.coords, other_coords)
    norm_p = known.norm * norm(other_coords)

    dot_p / norm_p * 100
  end

  defp dot_product([], []), do: 0

  defp dot_product([p | p_tail], [q | q_tail]) do
    p * q + dot_product(p_tail, q_tail)
  end

  def norm(coords) do
    coords
    |> Enum.reduce(0, fn n, acc -> n ** 2 + acc end)
    |> :math.sqrt()
  end
end
