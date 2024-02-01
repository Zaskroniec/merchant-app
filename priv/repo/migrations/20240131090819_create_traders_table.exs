defmodule Merchant.Repo.Migrations.CreateTradersTable do
  use Ecto.Migration

  def change do
    create table(:traders) do
      add :guid, :string, null: false
      add :email, :string, null: false
      add :reference, :string, null: false
      add :live_on, :date, null: false
      add :disbursement_frequency, :string, null: false
      add :minimum_monthly_fee, :money_with_currency, null: false
    end

    create unique_index(:traders, :guid)
    create unique_index(:traders, :reference)
  end
end
