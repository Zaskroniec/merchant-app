defmodule Merchant.Transactions.Trader do
  use Ecto.Schema

  import Ecto.Changeset

  alias Merchant.Transactions.Disbursement
  alias Merchant.Transactions.Order

  @type t :: %__MODULE__{}

  @frequencies ~w(weekly daily)a

  schema "traders" do
    field :guid, :string
    field :email, :string
    field :reference, :string
    field :live_on, :date
    field :disbursement_frequency, Ecto.Enum, values: @frequencies
    field :minimum_monthly_fee, Money.Ecto.Composite.Type

    has_many :orders, Order
    has_many :disbursements, Disbursement
  end

  @import_fields ~w(guid email reference live_on disbursement_frequency minimum_monthly_fee)a

  @spec frequencies() :: list(atom())
  def frequencies(), do: @frequencies

  @spec import_changeset(map()) :: Ecto.Changeset.t()
  def import_changeset(params) do
    %__MODULE__{}
    |> cast(params, @import_fields)
    |> validate_required(@import_fields)
    |> validate_inclusion(:disbursement_frequency, @frequencies)
  end
end
