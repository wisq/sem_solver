defmodule Semantle43Test do
  use SemSolver.SemantleCase, async: true

  @target "greet"
  @guesses [
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

  test "guess list is accurate" do
    assert_guesses_accurate(@target, @guesses)
  end

  test "can find target word using two random guesses" do
    assert_solved_in(2, @target, @guesses)
  end
end
