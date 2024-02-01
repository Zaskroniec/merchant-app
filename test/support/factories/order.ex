defmodule Merchant.Factories.Order do
  alias Merchant.Transactions.Order

  defmacro __using__(_opts) do
    quote do
      def order_factory(attrs) do
        trader = Map.get_lazy(attrs, :trader, fn -> insert(:trader) end)

        order =
          %Order{
            trader: trader,
            guid: Ecto.UUID.generate(),
            trader_reference: trader.reference,
            amount: Money.new(1_000),
            created_at: Timex.today()
          }

        order
        |> merge_attributes(attrs)
        |> evaluate_lazy_attributes()
      end
    end
  end
end
