defmodule Semantle44Test do
  use SemSolver.SemantleCase, async: true

  @target "track"
  @guesses [
    velvet: -3.65,
    rack: 14.96,
    shelf: 11.02,
    solo: 12.65,
    nick: 7.58,
    flux: 8.94,
    international: 5.91,
    recruiting: 12.27,
    forestry: 5.61,
    ash: 0.11,
    reduce: 5.27,
    sale: 5.58
  ]

  test "guess list is accurate" do
    assert_guesses_accurate(@target, @guesses)
  end

  test "can find target word using two random guesses" do
    assert_solved_in(2, @target, @guesses)
  end
end
