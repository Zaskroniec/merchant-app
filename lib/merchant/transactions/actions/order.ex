defmodule Merchant.Transactions.Actions.Order do
  @moduledoc """
  Actions related to order struct within Transaction context
  """
  alias Merchant.Repo
  alias Merchant.Transactions.Order
  alias Merchant.Transactions.Trader

  @doc """
  Persist trader struct for given param

  ## Examples

      iex> Order.create(trader, params)
  """
  @spec create(Trader.t(), map()) :: {:ok, Trader.t()} | {:error, Ecto.Changeset.t()}
  def create(trader, params) do
    trader
    |> Order.insert_changeset(params)
    |> Repo.insert()
  end
end
