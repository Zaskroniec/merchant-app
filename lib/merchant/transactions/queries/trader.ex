defmodule Merchant.Transactions.Queries.Trader do
  @moduledoc """
  Queries related to trader struct within Transactions context
  """
  import Ecto.Query

  alias Merchant.Repo
  alias Merchant.Transactions.Trader

  @doc """
  Fetch trader for given reference or id. Raises exception if row is not found.

  ## Examples

      iex> Trader.get!("dummy_reference")
      %Trader{}

      iex> Trader.get!(1)
      %Trader{}
  """
  @spec get!(binary()) :: Trader.t()
  def get!(reference) when is_binary(reference) do
    Trader
    |> from(as: :traders)
    |> where([traders: t], t.reference == ^reference)
    |> Repo.one!()
  end

  def get!(id) do
    Repo.get!(Trader, id)
  end
end
