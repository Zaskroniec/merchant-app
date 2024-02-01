defmodule Merchant.Transactions.Queries.OrderTest do
  use Merchant.DataCase, async: true

  alias Merchant.Transactions.Queries.Order

  setup do
    trader = insert(:trader)

    {:ok, trader: trader}
  end

  describe "list_for_date/2" do
    test "returns list of maps for given trader and date", %{trader: trader} do
      date = ~D[2024-01-01]

      _legacy_order = insert(:order, trader: trader, created_at: ~D[2023-12-31])
      %{id: order_1_id} = insert(:order, trader: trader, created_at: ~D[2024-01-01])
      %{id: order_2_id} = insert(:order, trader: trader, created_at: ~D[2024-01-01])
      _future_order = insert(:order, trader: trader, created_at: ~D[2024-01-02])

      ids = trader |> Order.list_for_date(date) |> Enum.map(& &1.id)

      assert order_1_id in ids
      assert order_2_id in ids
    end
  end

  describe "exists_disbursements_in_the_month?/2" do
    test "exists orders for given date cycle", %{trader: trader} do
      date = ~D[2024-01-01]
      disbursement_reference = Merchant.ReferenceGenerator.from_word_date(trader.reference, date)

      insert(:order,
        trader: trader,
        disbursement_reference: disbursement_reference,
        commission_fee: %Money{amount: 123, currency: :EUR},
        created_at: ~D[2024-01-01]
      )

      assert Order.exists_disbursements_in_the_month?(trader, date)
    end

    test "does not exists orders for given date cycle", %{trader: trader} do
      date = ~D[2024-01-01]
      disbursement_reference = Merchant.ReferenceGenerator.from_word_date(trader.reference, date)

      insert(:order,
        trader: trader,
        disbursement_reference: disbursement_reference,
        commission_fee: %Money{amount: 123, currency: :EUR},
        created_at: ~D[2023-12-31]
      )

      refute Order.exists_disbursements_in_the_month?(trader, date)
    end
  end

  describe "sum_previous_monthly_commissions/2" do
    test "sum order for given date and trader", %{trader: trader} do
      date = ~D[2024-01-01]
      disbursement_reference = Merchant.ReferenceGenerator.from_word_date(trader.reference, date)

      insert(:order,
        trader: trader,
        disbursement_reference: disbursement_reference,
        commission_fee: %Money{amount: 123, currency: :EUR},
        created_at: ~D[2023-12-26]
      )

      insert(:order,
        trader: trader,
        disbursement_reference: disbursement_reference,
        commission_fee: %Money{amount: 67, currency: :EUR},
        created_at: ~D[2023-12-25]
      )

      insert(:order, created_at: ~D[2023-12-02])

      assert Order.sum_previous_monthly_commissions(trader, date) == 190
    end

    test "returns nil for given date and trader", %{trader: trader} do
      date = ~D[2024-01-01]

      refute Order.sum_previous_monthly_commissions(trader, date)
    end
  end
end
