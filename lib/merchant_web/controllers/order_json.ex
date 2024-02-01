defmodule MerchantWeb.OrderJSON do
  def show(%{order: order}) do
    %{data: data(order)}
  end

  defp data(order) do
    order
    |> Map.take([:guid, :amount, :created_at])
    |> Map.put(:merchant_reference, order.trader_reference)
    |> Map.put(:amount, Map.from_struct(order.amount))
  end
end
