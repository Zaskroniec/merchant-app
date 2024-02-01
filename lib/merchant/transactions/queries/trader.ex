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
  @spec get!(binary() | non_neg_integer()) :: Trader.t()
  def get!(reference) when is_binary(reference) do
    Trader
    |> from(as: :traders)
    |> where([traders: t], t.reference == ^reference)
    |> Repo.one!()
  end

  def get!(id) do
    Repo.get!(Trader, id)
  end

  @doc """
  Fetch a list of trader IDs for a given date. If a trader has
  `disbursement_frequency == :weekly`, it should include such a trader
  if the day of the week from the live_on column matches the given date.

  ## Examples

      iex> Trader.for_disbursements(~D[2024-01-31])
      [1, 2, 3]
  """
  @spec for_disbursements(Date.t()) :: list(non_neg_integer())
  def for_disbursements(date) do
    day_of_week_today = Date.day_of_week(date)

    Trader
    |> from(as: :traders)
    |> where(
      [traders: t],
      t.disbursement_frequency == :daily or
        fragment("EXTRACT(ISODOW FROM ?) = ?", t.live_on, ^day_of_week_today)
    )
    |> select([traders: t], t.id)
    |> Repo.all()
  end

  @doc """
  Fetch a list of trader IDs

  ## Examples

      iex> Trader.all_ids
      [1, 2, 3]
  """
  @spec all_ids() :: list(non_neg_integer())
  def all_ids() do
    Trader
    |> from(as: :traders)
    |> select([traders: t], t.id)
    |> Repo.all()
  end
end
