defmodule Merchant.Transactions.Workers.TradersDisbursements do
  @moduledoc """
  Worker resposible for scheduling daily process for calculating commissions and disbursements. It supports
  option to process all historic data i.e by starting date like "2020-01-01" (it will iterate over each day till next closest cycle)
  """
  use Oban.Worker,
    queue: :default,
    priority: 1,
    max_attempts: 1,
    tags: ["order"],
    unique: [fields: [:queue, :worker, :args]]

  alias Merchant.Transactions.Queries.Trader
  alias Merchant.Transactions.Workers.TraderDisbursements

  @impl Oban.Worker
  @spec perform(Oban.Job.t()) :: :ok
  def perform(%Oban.Job{args: %{"date" => date, "historic" => "true"}}) do
    date = Date.from_iso8601!(date)
    ids = Trader.all_ids()

    Enum.each(ids, fn trader_id ->
      %{"trader_id" => trader_id, "date" => date, "historic" => "true"}
      |> TraderDisbursements.new()
      |> Oban.insert()
    end)

    :ok
  end

  def perform(%Oban.Job{}) do
    historic = "false"
    date = Timex.today()

    date
    |> Trader.for_disbursements()
    |> Enum.each(fn trader_id ->
      %{"trader_id" => trader_id, "date" => date, "historic" => historic}
      |> TraderDisbursements.new()
      |> Oban.insert()
    end)

    :ok
  end
end
