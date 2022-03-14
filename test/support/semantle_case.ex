defmodule SemSolver.SemantleCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import SemSolver.SemantleCase
    end
  end

  alias SemSolver.{WordStream, KnownWord, Word}

  def assert_guesses_accurate(target, %{} = guesses) when is_binary(target) do
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
      fn guesses ->
        assert(
          %Word{word: ^target} = SemSolver.solve(guesses),
          "Failed to find #{inspect(target)} using guesses #{inspect(guesses)}"
        )
      end,
      timeout: 30_000,
      ordered: false
    )
    |> Stream.run()
  end
end
