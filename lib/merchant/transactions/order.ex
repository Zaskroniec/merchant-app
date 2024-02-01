defmodule Merchant.Transactions.Order do
  use Ecto.Schema

  import Ecto.Changeset

  alias Merchant.Transactions.Trader

  @type t :: %__MODULE__{}
  @currencies ~w(EUR)a

  schema "orders" do
    field :guid, :string
    field :trader_reference, :string
    field :disbursement_reference, :string
    field :disbursement_date, :date
    field :commission_fee, Money.Ecto.Composite.Type
    field :amount, Money.Ecto.Composite.Type
    field :created_at, :date

    belongs_to :trader, Trader
  end

  @import_fields ~w(guid trader_reference amount created_at trader_id)a
  @insert_fields @import_fields -- ~w(trader_reference trader_id created_at)a

  @spec import_changeset(map()) :: Ecto.Changeset.t()
  def import_changeset(params) do
    %__MODULE__{}
    |> cast(params, @import_fields)
    |> validate_required(@import_fields)
  end

  @spec insert_changeset(Trader.t(), map()) :: Ecto.Changeset.t()
  def insert_changeset(trader, params) do
    %__MODULE__{}
    |> cast(params, @insert_fields)
    |> validate_required(@insert_fields)
    |> validate_amount(:amount)
    |> validate_currency(:amount)
    |> change(
      created_at: Timex.today(),
      trader_reference: trader.reference
    )
    |> put_assoc(:trader, trader)
    |> unique_constraint(:guid)
  end

  defp validate_amount(changeset, field) do
    validate_change(changeset, field, fn
      _, %Money{amount: amount} when amount > 0 -> []
      _, _ -> [amount: "must be greater than 0"]
    end)
  end

  defp validate_currency(changeset, field) do
    validate_change(changeset, field, fn
      _, %Money{currency: currency} when currency in @currencies -> []
      _, _ -> [amount: "invalid currency"]
    end)
  end
end
