defmodule SemSolver.WordStream do
  alias SemSolver.Word

  def file!(path) do
    Stream.resource(
      fn ->
        file = File.open!(path)
        # throw away header (for now)
        IO.read(file, :line)
        file
      end,
      fn file ->
        case IO.read(file, :line) do
          data when is_binary(data) -> {[Word.parse(data)], file}
          _ -> {:halt, file}
        end
      end,
      fn file -> File.close(file) end
    )
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
