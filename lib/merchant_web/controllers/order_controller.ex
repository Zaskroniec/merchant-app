defmodule MerchantWeb.OrderController do
  use MerchantWeb, :controller

  alias Merchant.Transactions.Actions
  alias Merchant.Transactions.Queries

  action_fallback MerchantWeb.FallbackController

  def create(conn, %{"merchant_reference" => merchant_reference, "data" => params}) do
    trader = Queries.Trader.get!(merchant_reference)

    case Actions.Order.create(trader, params) do
      {:ok, order} ->
        render(conn, :show, order: order)

      {:error, _changeset} ->
        {:error, :unprocessable_entity}
    end
  end
end
