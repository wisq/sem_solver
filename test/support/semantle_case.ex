defmodule SemSolver.SemantleCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import SemSolver.SemantleCase
    end
  end

  alias SemSolver.{WordStream, KnownWord, Word}

  def assert_guesses_accurate(target, guesses) when is_binary(target) do
    guesses = guesses |> Map.new(fn {k, v} -> {Atom.to_string(k), v} end)
    wanted = [target | Map.keys(guesses)]

    all_found =
      SemSolver.default_dataset()
      |> WordStream.find_words(wanted)
      |> Map.new(&{&1.word, &1})

    {target, others} = Map.pop!(all_found, target)
    known = KnownWord.from_word(target)

    scores =
      others
      |> Map.new(fn {_, w} ->
        {w.word, KnownWord.distance(known, w) |> Float.round(2)}
      end)

    assert scores == guesses
  end

  def assert_solved_in(n_g, target, all_guesses) do
    count = Enum.count(all_guesses)
    assert rem(count, n_g) == 0, "Number of guesses (#{count}) must be divisible by #{n_g}"

    all_guesses
    |> Enum.shuffle()
    |> Enum.chunk_every(n_g)
    |> Task.async_stream(
      fn guesses -> {guesses, SemSolver.solve(guesses)} end,
      timeout: 30_000,
      ordered: false
    )
    |> Enum.each(fn {:ok, {guesses, found}} ->
      assert %Word{word: word} = found

      assert word == target,
             "Expected #{inspect(target)}, got #{inspect(word)} using guesses #{inspect(guesses)}"
    end)
  end
end
