defmodule SemSolver.WordStream do
  alias SemSolver.Word

  defmodule FileSplitter do
    def split_file!(path, parts \\ 10000) do
      file = File.open!(path)
      {:ok, size} = :file.position(file, {:eof, 0})
      chunk_size = div(size, parts) + 1

      {chunks, ^size} =
        0..size//chunk_size
        |> Enum.concat([size])
        |> Enum.uniq()
        |> Enum.flat_map_reduce(0, &find_linebreak(file, &1, &2))

      chunks
      |> Enum.map(&partial_stream(path, &1))
    end

    defp find_linebreak(_, 0, 0), do: {[], 0}

    defp find_linebreak(file, offset, last_offset) do
      {:ok, ^offset} = :file.position(file, {:bof, offset})
      IO.read(file, :line)
      {:ok, new_offset} = :file.position(file, {:cur, 0})

      cond do
        last_offset < new_offset -> {[last_offset..(new_offset - 1)], new_offset}
        last_offset == new_offset -> {[], new_offset}
      end
    end

    defp partial_stream(path, start..stop) do
      Stream.resource(
        fn ->
          file = File.open!(path)
          {:ok, ^start} = :file.position(file, {:bof, start})
          file
        end,
        fn file ->
          {:ok, offset} = :file.position(file, {:cur, 0})

          if offset >= stop do
            {:halt, file}
          else
            word = IO.read(file, :line) |> Word.parse()
            {[word], file}
          end
        end,
        fn file ->
          File.close(file)
        end
      )
    end
  end

  def file!(path) do
    FileSplitter.split_file!(path)
  end

  def find_words(stream, search_words) do
    stream
    |> Task.async_stream(&find_in_stream(&1, fn w -> w.word in search_words end), ordered: false)
    |> Stream.flat_map(fn {:ok, words} when is_list(words) -> words end)
    |> Enum.reduce_while({[], search_words}, &find_words_reducer/2)
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

  def find_word(stream, filter) do
    stream
    |> Task.async_stream(&find_in_stream(&1, filter), ordered: false)
    |> Enum.find_value(fn
      {:ok, [word | _]} -> word
      {:ok, []} -> nil
    end)
  end

  defp find_in_stream(stream, filter) do
    stream
    |> Enum.filter(filter)
  end
end
