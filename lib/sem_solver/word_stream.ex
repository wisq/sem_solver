defmodule SemSolver.WordStream do
  alias SemSolver.Word

  @float_size 4

  def file!(path) do
    Stream.resource(
      fn ->
        file = File.open!(path, [:binary, :compressed])

        [_count, size] =
          IO.binread(file, :line)
          |> :string.chomp()
          |> String.split(" ", parts: 2)
          |> Enum.map(&String.to_integer/1)

        read_len = @float_size * size
        {file, read_len}
      end,
      fn {file, read_len} = state ->
        case read_record(file, read_len) do
          {:ok, text, coords} ->
            {[Word.new(text, coords)], state}

          {:error, :eof} ->
            {:halt, state}
        end
      end,
      fn {file, _} -> File.close(file) end
    )
  end

  defp read_record(file, read_len) do
    data = IO.binread(file, read_len)

    if data == :eof do
      {:error, :eof}
    else
      [word, leftover] = String.split(data, " ", parts: 2)
      {:ok, word, read_coords(file, read_len, leftover)}
    end
  end

  defp read_coords(file, read_len, leftover) do
    leftover <> IO.binread(file, read_len - byte_size(leftover))
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
