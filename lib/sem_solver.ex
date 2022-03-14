defmodule SemSolver do
  require Logger
  alias SemSolver.{WordStream, KnownWord, Word}

  @data_set "GoogleNews-vectors-negative300"
  @data_file Path.join([:code.priv_dir(:sem_solver), "data", "#{@data_set}.bin.gz"])

  def default_dataset, do: WordStream.file!(@data_file)

  def solve(word_scores) do
    {usecs, word} = :timer.tc(&solve_with/2, [@data_file, word_scores])
    Logger.debug("Total solve time was #{div(usecs, 1000)}ms")
    word
  end

  def solve_with(data_file, %{} = word_scores) do
    dataset = WordStream.file!(data_file)

    {usecs, checks} = :timer.tc(&create_checks/2, [dataset, word_scores])
    Logger.debug("Found #{Enum.count(checks)} reference words in #{div(usecs, 1000)}ms")

    {usecs, word} = :timer.tc(&find_matching_word/2, [dataset, checks])
    Logger.debug("Matched #{inspect(word.word)} in #{div(usecs, 1000)}ms")

    word
  end

  defp create_checks(dataset, word_scores) do
    WordStream.find_words(dataset, Map.keys(word_scores))
    |> Enum.map(&generate_check_fn(&1, word_scores))
  end

  defp find_matching_word(dataset, checks) do
    dataset
    |> Enum.find(fn word -> checks |> Enum.all?(& &1.(word)) end)
  end

  defp generate_check_fn(%Word{} = word, word_scores) do
    known = KnownWord.from_word(word)
    score = Map.fetch!(word_scores, word.word)

    fn other ->
      distance = KnownWord.distance(known, other) |> Float.round(2)
      distance == score
    end
  end
end
