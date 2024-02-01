defmodule Merchant.Transactions.Queries.Order do
  @moduledoc """
  Queries related to order struct within Transactions context
  """

  import Ecto.Query

  alias Merchant.Repo
  alias Merchant.Transactions.Order
  alias Merchant.Transactions.Trader

  @doc """
  Fetch list of order maps for given trader and date

  ## Examples

      iex> Order.list_for_date(trader, ~D[2024-01-01])
      [%{}, %{}]
  """
  @spec list_for_date(Trader.t(), Date.t()) :: list(map())
  def list_for_date(trader, date) do
    Order
    |> from(as: :orders)
    |> where([orders: o], o.trader_reference == ^trader.reference)
    |> filter_by_trader_frequency(trader, date)
    |> where([orders: o], is_nil(o.disbursement_reference))
    |> select([orders: o], %{
      id: o.id,
      guid: o.guid,
      amount: o.amount,
      trader_reference: o.trader_reference,
      created_at: o.created_at,
      trader_id: o.trader_id
    })
    |> Repo.all()
  end

  @doc """
  Check whenever orders for given date and trade exists. It could be used when
  system need to determine when monthly fees should be generated.

  ## Examples

      iex> Order.exists_disbursements_in_the_month?(trader, ~D[2024-01-01])
      true
  """
  @spec exists_disbursements_in_the_month?(Trader.t(), Date.t()) :: boolean()
  def exists_disbursements_in_the_month?(trader, date) do
    start_date = Timex.beginning_of_month(date)

    Order
    |> from(as: :orders)
    |> where([orders: o], o.trader_reference == ^trader.reference)
    |> where([orders: o], o.created_at >= ^start_date and o.created_at <= ^date)
    |> where([orders: o], not is_nil(o.disbursement_reference))
    |> Repo.exists?()
  end

  @doc """
  Perform a sum on all orders for a given trader and date.
  The date is converted to a range, which starts at
  the beginning of the month and ends at the end of the month.
  Use this range to calculate all commissions throughout the entire month.

  ## Examples

      iex> Order.sum_previous_monthly_commissions(trader, ~D[2024-01-01])
      100
  """
  @spec sum_previous_monthly_commissions(Trader.t(), Date.t()) :: non_neg_integer() | nil
  def sum_previous_monthly_commissions(trader, date) do
    previous_month_date = Timex.shift(date, months: -1)
    start_date = Timex.beginning_of_month(previous_month_date)
    end_date = Timex.end_of_month(previous_month_date)

    Order
    |> from(as: :orders)
    |> where([orders: o], o.trader_reference == ^trader.reference)
    |> where([orders: o], o.created_at >= ^start_date and o.created_at <= ^end_date)
    |> where([orders: o], not is_nil(o.disbursement_reference))
    |> where([orders: o], not is_nil(o.commission_fee))
    |> select([orders: o], fragment("SUM((?).amount)", o.commission_fee))
    |> Repo.one()
  end

  defp filter_by_trader_frequency(query, %Trader{disbursement_frequency: :daily}, date) do
    where(query, [orders: o], o.created_at == ^date)
  end

  defp filter_by_trader_frequency(query, %Trader{disbursement_frequency: :weekly}, date) do
    begging_of_the_cycle_date = Timex.shift(date, days: -7)

    where(
      query,
      [orders: o],
      o.created_at >= ^begging_of_the_cycle_date and o.created_at <= ^date
    )
  end
end
