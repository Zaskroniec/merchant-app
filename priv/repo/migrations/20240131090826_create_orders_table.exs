defmodule Merchant.Repo.Migrations.CreateOrdersTable do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :guid, :string, null: false
      add :trader_reference, :string, null: false
      add :amount, :money_with_currency, null: false
      add :created_at, :date, null: false
      add :disbursement_reference, :string
      add :disbursement_date, :date
      add :commission_fee, :money_with_currency

      add :trader_id, references(:traders, on_delete: :delete_all), null: false
    end

    create index(:orders, :trader_reference)
    create index(:orders, :trader_id)
    create unique_index(:orders, :guid)

    create index(:orders, :disbursement_reference, where: "disbursement_reference IS NOT NULL")
  end
end
