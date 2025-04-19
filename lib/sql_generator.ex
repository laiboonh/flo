defmodule SqlGenerator do
  @spec batch_insert(list(MeterReading.t())) :: String.t()
  def batch_insert(meter_readings) do
    values =
      Enum.map(meter_readings, fn %MeterReading{
                                    nmi: nmi,
                                    timestamp: timestamp,
                                    consumption: consumption
                                  } ->
        "('#{nmi}', '#{timestamp}', #{consumption})"
      end)
      |> Enum.join(",")

    "INSERT INTO meter_readings (nmi, timestamp, consumption) VALUES #{values};"
  end
end
