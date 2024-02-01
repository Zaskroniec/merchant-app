defmodule Merchant.Repo.Migrations.CreateDisbursementsTable do
  use Ecto.Migration

  def change do
    create table(:disbursements) do
      add :amount, :money_with_currency, null: false
      add :reference, :string, null: false
      add :trader_id, references(:traders, on_delete: :delete_all), null: false
      add :disbursement_date, :date
    end

    create unique_index(:disbursements, [:trader_id, :reference])
  end
end
