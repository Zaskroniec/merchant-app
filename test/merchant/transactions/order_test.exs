defmodule Merchant.Transactions.OrderTest do
  use Merchant.DataCase, async: true

  alias Merchant.Transactions.Order

  describe "insert_changeset/3" do
    setup do
      trader = insert(:trader)

      {:ok, trader: trader}
    end

    test "returns valid changeset", %{trader: trader} do
      params = %{
        guid: Ecto.UUID.generate(),
        amount: %Money{amount: 100, currency: :EUR}
      }

      changeset = Order.insert_changeset(trader, params)

      assert changeset.valid?
    end

    test "returns invalid changeset with missing required fields", %{trader: trader} do
      params = %{
        guid: Ecto.UUID.generate()
      }

      changeset = Order.insert_changeset(trader, params)

      refute changeset.valid?

      assert %{amount: ["can't be blank"]} = errors_on(changeset)
    end

    test "returns invalid changeset with negative amount", %{trader: trader} do
      params = %{
        guid: Ecto.UUID.generate(),
        amount: %Money{amount: -100, currency: :EUR}
      }

      changeset = Order.insert_changeset(trader, params)

      refute changeset.valid?

      assert %{amount: ["must be greater than 0"]} = errors_on(changeset)
    end

    test "returns invalid changeset with invalid currency", %{trader: trader} do
      params = %{
        guid: Ecto.UUID.generate(),
        amount: %Money{amount: 100, currency: "INVALID_CURRENCY"}
      }

      changeset = Order.insert_changeset(trader, params)

      refute changeset.valid?

      assert %{amount: ["invalid currency"]} = errors_on(changeset)
    end
  end

  describe "import_changeset/1" do
    test "returns valid import changeset" do
      order_params = %{
        guid: Ecto.UUID.generate(),
        trader_reference: "test_reference",
        amount: %Money{amount: 100, currency: :EUR},
        created_at: ~D[2024-01-01],
        trader_id: 1
      }

      changeset = Order.import_changeset(order_params)

      assert changeset.valid?
    end

    test "returns invalid import changeset with missing required fields" do
      order_params = %{
        guid: Ecto.UUID.generate(),
        amount: %Money{amount: 100, currency: :EUR},
        created_at: ~D[2024-01-01]
      }

      changeset = Order.import_changeset(order_params)

      refute changeset.valid?

      assert %{trader_reference: ["can't be blank"]} = errors_on(changeset)
    end
  end
end
