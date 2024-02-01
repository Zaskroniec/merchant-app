defmodule Merchant.Imports.Queries.Trader do
  @moduledoc """
  Queries related to trader struct within Imports context
  """
  import Ecto.Query

  alias Merchant.Repo
  alias Merchant.Transactions.Trader

  @doc """
  Fetch trader ids and reduce them into map with reference -> id format

  ## Examples

      iex> Trader.map_ids_by_references()
      %{"dummy_reference" => trader_id}
  """
  @spec map_ids_by_references() :: map()
  def map_ids_by_references() do
    Trader
    |> from(as: :traders)
    |> select([traders: t], {t.reference, t.id})
    |> Repo.all()
    |> Enum.reduce(%{}, fn {reference, id}, acc ->
      Map.put(acc, reference, id)
    end)
  end
end
