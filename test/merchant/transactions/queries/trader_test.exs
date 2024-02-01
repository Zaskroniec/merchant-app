defmodule Merchant.Transactions.Queries.TraderTest do
  use Merchant.DataCase, async: true

  alias Merchant.Transactions.Queries.Trader

  describe "get!/1" do
    test "returns trader for given reference" do
      trader = insert(:trader)

      assert Trader.get!(trader.reference) == trader
    end

    test "raises exception for given param" do
      assert_raise Ecto.NoResultsError, fn ->
        Trader.get!("x")
      end
    end
  end
end
