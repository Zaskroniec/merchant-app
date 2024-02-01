defmodule Merchant.Transactions.Workers.TraderDisbursements do
  @moduledoc """
  Worker resposible for calculating commissions and disbursements for specific trader and given date
  """
  use Oban.Worker,
    queue: :default,
    priority: 1,
    max_attempts: 1,
    tags: ["order"],
    unique: [fields: [:queue, :worker, :args]]

  alias Merchant.ReferenceGenerator
  alias Merchant.Repo
  alias Merchant.Transactions.Disbursement
  alias Merchant.Transactions.Order
  alias Merchant.Transactions.Queries

  @impl Oban.Worker
  @spec perform(Oban.Job.t()) :: :ok
  def perform(%Oban.Job{
        args: %{"trader_id" => trader_id, "date" => date, "historic" => historic}
      }) do
    trader = Queries.Trader.get!(trader_id)
    date = Date.from_iso8601!(date)

    perform(trader, date, historic)

    :ok
  end

  defp perform(trader, date, historic) do
    orders_from_date = Timex.shift(date, days: -1)
    payload = build_payload(trader, orders_from_date, date)

    maybe_handle_first_disbursement_in_month(trader, orders_from_date)

    if Enum.any?(payload) do
      Repo.transaction(fn repo ->
        repo.insert_all(
          Order,
          payload,
          on_conflict: {:replace, [:disbursement_date, :disbursement_reference, :commission_fee]},
          conflict_target: :guid
        )
      end)
    end

    maybe_process_next_day(trader, date, historic)
  end

  defp build_payload(trader, orders_from_date, date) do
    disbursement_reference = Merchant.ReferenceGenerator.from_word_date(trader.reference, date)
    disbursement_date = date

    trader
    |> Queries.Order.list_for_date(orders_from_date)
    |> Enum.map(fn %{amount: amount} = data ->
      commission_fee = Merchant.Transactions.CommissionCalculator.calculate(amount)

      data
      |> Map.put(:disbursement_reference, disbursement_reference)
      |> Map.put(:commission_fee, commission_fee)
      |> Map.put(:disbursement_date, disbursement_date)
    end)
  end

  defp maybe_handle_first_disbursement_in_month(trader, orders_from_date) do
    if Queries.Order.exists_disbursements_in_the_month?(trader, orders_from_date) do
      :noop
    else
      monthly_commission =
        Queries.Order.sum_previous_monthly_commissions(trader, orders_from_date) || 0

      monthly_commission = Money.new(monthly_commission)
      monthly_diff_fees = Money.add(trader.minimum_monthly_fee, Money.neg(monthly_commission))

      case {Money.cmp(monthly_diff_fees, trader.minimum_monthly_fee),
            Money.cmp(monthly_diff_fees, Money.new(0))} do
        {:lt, :gt} -> create_monthly_fees(trader, monthly_diff_fees, orders_from_date)
        _ -> :noop
      end
    end
  end

  defp create_monthly_fees(trader, fees, orders_from_date) do
    previous_cycle = Timex.shift(orders_from_date, months: -1)
    reference = ReferenceGenerator.from_date(previous_cycle)

    trader
    |> Disbursement.insert_changeset(fees, reference, previous_cycle)
    |> Repo.insert!(on_conflict: :nothing)
  end

  defp maybe_process_next_day(trader, date, "true" = historic) do
    latest_cycle = Timex.shift(Timex.today(), days: -1)

    if Timex.before?(date, latest_cycle) do
      next_cycle = Timex.shift(date, days: 1)

      perform(trader, next_cycle, historic)
    else
      :noop
    end
  end

  defp maybe_process_next_day(_trader, _date, _historic), do: :noop
end
