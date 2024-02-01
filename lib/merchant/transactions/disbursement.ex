defmodule Merchant.Transactions.Disbursement do
  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  alias Merchant.Transactions.Trader

  schema "disbursements" do
    field :amount, Money.Ecto.Composite.Type
    field :reference, :string
    field :disbursement_date, :date

    belongs_to :trader, Trader
  end

  def insert_changeset(trader, amount, reference, disbursement_date) do
    %__MODULE__{}
    |> change(
      trader_id: trader.id,
      amount: amount,
      reference: reference,
      disbursement_date: disbursement_date
    )
  end
end
