defmodule MeterReading do
  @type t :: %MeterReading{nmi: String.t(), timestamp: Date.t(), consumption: float()}

  defstruct [:nmi, :timestamp, :consumption]

  @spec new(map()) :: MeterReading.t()
  def new(data) do
    %MeterReading{
      nmi: data.nmi,
      timestamp: to_date(data.timestamp),
      consumption: Float.parse(data.consumption) |> elem(0)
    }
  end

  @spec to_date(String.t()) :: Date.t()
  defp to_date(timestamp) do
    <<year::binary-size(4), month::binary-size(2), day::binary-size(2)>> = timestamp
    Date.from_iso8601!("#{year}-#{month}-#{day}")
  end
end
