defmodule Flo do
  @relevent_record_types ["200", "300"]
  @interval_length_index 6
  @consumption_values_formula 1440

  @spec process(String.t()) :: [String.t()]
  def process(absolute_path) do
    File.stream!(absolute_path, :line)
    |> stream()
    |> generate_sql_statements()
    |> Enum.to_list()
  end

  @spec stream(File.Stream.t()) :: Enumerable.t()
  def stream(file_stream_by_line) do
    chunk_fun = fn element, acc ->
      record = String.split(element, ",")

      if Enum.at(record, 0) in @relevent_record_types do
        {:cont, [element | acc]}
      else
        {:cont, Enum.reverse(acc), []}
      end
    end

    after_fun = fn
      [] ->
        {:cont, []}

      acc ->
        {:cont, acc, []}
    end

    file_stream_by_line
    |> Stream.chunk_while([], chunk_fun, after_fun)
    |> Stream.reject(fn chunk -> chunk == [] end)
  end

  @spec generate_sql_statements(Enumerable.t()) :: Enumerable.t()
  def generate_sql_statements(stream) do
    stream
    |> Stream.map(fn [record_200 | record_300s] ->
      ["200", nmi | rest] = String.split(record_200, ",")
      interval_length = Enum.at(rest, @interval_length_index) |> String.to_integer()
      number_of_interval_values = (@consumption_values_formula / interval_length) |> round()

      record_300s
      |> Enum.map(fn record ->
        ["300", timestamp | rest] = String.split(record, ",")

        get_consumption_values(rest, number_of_interval_values)
        |> Enum.map(fn value ->
          MeterReading.new(%{nmi: nmi, timestamp: timestamp, consumption: value})
        end)
        |> SqlGenerator.batch_insert()
      end)
    end)
  end

  @spec get_consumption_values(list(String.t()), integer()) :: list(String.t())
  defp get_consumption_values(data, number_of_interval_values) do
    0..(number_of_interval_values - 1)
    |> Enum.map(fn index -> Enum.at(data, index) end)
  end
end
