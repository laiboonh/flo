defmodule SqlGeneratorTest do
  use ExUnit.Case

  describe "batch_insert" do
    test "success" do
      assert SqlGenerator.batch_insert([
               MeterReading.new(%{nmi: "NEM1201009", timestamp: "20050301", consumption: "0.461"}),
               MeterReading.new(%{nmi: "NEM1201009", timestamp: "20050302", consumption: "0.810"})
             ]) ==
               "INSERT INTO meter_readings (nmi, timestamp, consumption) VALUES ('NEM1201009', '2005-03-01', 0.461),('NEM1201009', '2005-03-02', 0.81);"
    end
  end
end
