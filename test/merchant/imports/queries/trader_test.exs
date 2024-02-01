defmodule Merchant.Imports.Queries.TraderTest do
  use Merchant.DataCase, async: true

  alias Merchant.Imports.Queries.Trader

  describe "map_ids_by_references/0" do
    test "map_ids_by_references returns a map of trader references to ids" do
      %{id: trader1_id} = insert(:trader, reference: "reference1")
      %{id: trader2_id} = insert(:trader, reference: "reference2")

      assert %{"reference1" => ^trader1_id, "reference2" => ^trader2_id} =
               Trader.map_ids_by_references()
    end
  end
end
