defmodule SemSolver.WordStream do
  alias SemSolver.Word

  def file!(path) do
    File.stream!(path)
    |> Stream.map(&Word.parse/1)
  end

  def find_words(stream, search_words) do
    Enum.reduce_while(stream, {[], search_words}, &find_words_reducer/2)
  end

  defp find_words_reducer(word, {found, search}) do
    acc =
      case word.word in search do
        true -> {[word | found], List.delete(search, word.word)}
        false -> {found, search}
      end

    case acc do
      {found, []} -> {:halt, found}
      other -> {:cont, other}
    end
  end
end
