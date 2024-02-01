defmodule Merchant.Transactions.TraderTest do
  use Merchant.DataCase, async: true

  alias Merchant.Transactions.Trader

  describe "import_changeset/1" do
    test "returns valid changeset" do
      trader_params = %{
        guid: "some_guid",
        email: "test@example.com",
        reference: "test_reference",
        live_on: ~D[2024-01-01],
        disbursement_frequency: "weekly",
        minimum_monthly_fee: %Money{amount: 100, currency: :EUR}
      }

      changeset = Trader.import_changeset(trader_params)

      assert changeset.valid?
    end

    test "returns invalid changeset with missing required fields" do
      trader_params = %{
        guid: "some_guid",
        reference: "test_reference",
        live_on: ~D[2024-01-01],
        disbursement_frequency: "weekly",
        minimum_monthly_fee: %Money{amount: 100, currency: :EUR}
      }

      changeset = Trader.import_changeset(trader_params)

      refute changeset.valid?
      assert %{email: ["can't be blank"]} = errors_on(changeset)
    end

    test "returns invalid changeset with invalid disbursement_frequency" do
      params = %{
        guid: "some_guid",
        email: "test@example.com",
        reference: "test_reference",
        live_on: ~D[2024-01-01],
        disbursement_frequency: "invalid_frequency",
        minimum_monthly_fee: %Money{amount: 100, currency: :EUR}
      }

      changeset = Trader.import_changeset(params)

      refute changeset.valid?
      assert %{disbursement_frequency: ["is invalid"]} = errors_on(changeset)
    end
  end
end
