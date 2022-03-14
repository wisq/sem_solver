defmodule Semantle43Test do
  use SemSolver.SemantleCase, async: true

  @target "greet"
  @guesses [
    orbit: 4.64,
    massive: 1.71,
    current: -0.26,
    argue: 5.56,
    typical: 9.50,
    voyeur: 4.44,
    overnight: 8.31,
    accept: 16.67,
    compound: 4.80,
    sauce: 0.89,
    handed: 11.04,
    preserve: 0.17
  ]

  test "guess list is accurate" do
    assert_guesses_accurate(@target, @guesses)
  end

  test "can find target word using two random guesses" do
    assert_solved_in(2, @target, @guesses)
  end
end
