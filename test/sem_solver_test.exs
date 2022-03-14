defmodule SemSolverTest do
  use ExUnit.Case, async: true

  alias SemSolver.Word

  test "handles different guess formats" do
    assert %Word{word: "track"} = SemSolver.solve(%{"rack" => 14.96})
    assert %Word{word: "track"} = SemSolver.solve(%{rack: 14.96})
    assert %Word{word: "track"} = SemSolver.solve(rack: 14.96)
  end

  test "rejects invalid scores" do
    # Valid because 13.0 == 13.00
    assert %Word{word: "track"} = SemSolver.solve(board: 13.0)
    # Invalid because too many decimal places:
    assert_raise(ArgumentError, fn -> SemSolver.solve(board: 13.001) end)
  end
end
