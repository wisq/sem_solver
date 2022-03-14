defmodule SemSolverTest do
  use ExUnit.Case

  guesses = [
    welcome: 40.83,
    invite: 38.02,
    taunt: 30.29,
    invitation: 27.30,
    tempt: 21.68,
    host: 21.51,
    accept: 16.67,
    allow: 15.71,
    open: 15.19,
    call: 14.14,
    eclipse: 11.50,
    handed: 11.04,
    typical: 9.50,
    overnight: 8.31,
    remove: 6.32,
    argue: 5.56,
    referral: 5.44,
    trust: 5.11,
    compound: 4.80,
    orbit: 4.64,
    space: 4.26,
    tackle: 3.68,
    difficult: 3.26,
    acquire: 2.95,
    nasty: 2.65,
    resort: 1.80,
    massive: 1.71,
    sauce: 0.89,
    preserve: 0.17,
    current: -0.26,
    value: -5.11,
    texture: -10.27
  ]

  @target "greet"
  @guesses Map.new(guesses, fn {w, s} -> {Atom.to_string(w), s} end)

  alias SemSolver.{WordStream, KnownWord, Word}

  test "guess list is accurate" do
    wanted = [@target | Map.keys(@guesses)]

    all_found =
      SemSolver.default_dataset()
      |> WordStream.find_words(wanted)
      |> Map.new(&{&1.word, &1})

    {target, others} = Map.pop!(all_found, @target)
    known = KnownWord.from_word(target)

    scores =
      others
      |> Map.new(fn {_, w} ->
        {w.word, KnownWord.distance(known, w) |> Float.round(2)}
      end)

    assert scores == @guesses
  end

  test "can find target word using two random guesses" do
    @guesses
    |> Enum.shuffle()
    |> Enum.chunk_every(2)
    |> Task.async_stream(
      fn guesses ->
        assert(
          %Word{word: @target} = Map.new(guesses) |> SemSolver.solve(),
          "Failed to find #{inspect(@target)} using guesses #{inspect(guesses)}"
        )
      end,
      timeout: 30_000
    )
    |> Stream.run()
  end
end
