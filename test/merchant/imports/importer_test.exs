defmodule Merchant.Imports.ImporterTest do
  use Merchant.DataCase, async: false

  alias Merchant.Imports.Importer
  alias Merchant.Repo
  alias Merchant.Transactions.Order
  alias Merchant.Transactions.Trader

  describe "import/2 :merchants" do
    test "imports 3 traders" do
      file_path = "/test/support/files/merchants.csv"
      resource_name = :traders

      assert :ok = Importer.import(file_path, resource_name)

      assert Repo.aggregate(Trader, :count, :guid) == 3
    end
  end

  describe "import/2 :orders" do
    test "imports only 2 orders and reject one due to invalid data" do
      insert(:trader, reference: "cormier_weissnat_and_hauck")
      insert(:trader, reference: "wisoky_llc")

      file_path = "/test/support/files/orders.csv"
      resource_name = :orders

      assert :ok = Importer.import(file_path, resource_name)

      assert Repo.aggregate(Order, :count, :guid) == 2
    end
  end
end
