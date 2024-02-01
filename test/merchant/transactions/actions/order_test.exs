defmodule Merchant.Transactions.Actions.OrderTest do
  use Merchant.DataCase, async: true

  alias Merchant.Transactions.Actions
  alias Merchant.Transactions.Order

  setup do
    trader = insert(:trader)

    {:ok, trader: trader}
  end

  describe "create/2" do
    test "creates order with valid parameters", %{trader: trader} do
      %{id: trader_id, reference: reference} = trader

      params = %{
        guid: Ecto.UUID.generate(),
        amount: %{amount: 1_000, currency: "eur"}
      }

      assert {:ok, order} = Actions.Order.create(trader, params)

      assert %Order{
               trader_id: ^trader_id,
               trader_reference: ^reference,
               amount: %Money{amount: 1_000, currency: :EUR}
             } = order
    end

    test "returns error for invalid parameters", %{trader: trader} do
      params = %{
        guid: Ecto.UUID.generate()
      }

      {:error, changeset} = Actions.Order.create(trader, params)

      assert %{amount: ["can't be blank"]} = errors_on(changeset)
    end

    test "returns error for non unique guid parameters", %{trader: trader} do
      order = insert(:order, trader: trader)

      params = %{
        guid: order.guid,
        amount: %{amount: 1_000, currency: "eur"}
      }

      {:error, changeset} = Actions.Order.create(trader, params)

      assert %{guid: ["has already been taken"]} = errors_on(changeset)
    end
  end
end
