defmodule Merchant.Transactions.Queries.TraderTest do
  use Merchant.DataCase, async: true

  alias Merchant.Transactions.Queries.Trader

  describe "get!/1" do
    test "returns trader for given reference" do
      trader = insert(:trader)

      assert Trader.get!(trader.reference) == trader
    end

    test "returns trader for given id" do
      trader = insert(:trader)

      assert Trader.get!(trader.id) == trader
    end

    test "raises exception for given param" do
      assert_raise Ecto.NoResultsError, fn ->
        Trader.get!(1)
      end
    end
  end

  describe "for_disbursements/1" do
    test "returns traders with daily frequency or matched day of the week" do
      date = ~D[2024-01-05]
      %{id: trader_1_id} = insert(:trader, disbursement_frequency: :daily)
      %{id: trader_2_id} = insert(:trader, disbursement_frequency: :weekly, live_on: date)

      %{id: trader_3_id} =
        insert(:trader, disbursement_frequency: :weekly, live_on: ~D[2024-01-06])

      result = Trader.for_disbursements(date)

      assert trader_1_id in result
      assert trader_2_id in result

      refute trader_3_id in result
    end
  end

  describe "all_ids/0" do
    test "returns list of ids" do
      ids =
        3
        |> insert_list(:trader)
        |> Enum.map(& &1.id)
        |> Enum.sort()

      assert ids == Trader.all_ids()
    end
  end
end
