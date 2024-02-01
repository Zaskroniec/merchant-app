defmodule Merchant.Factories.Disbursement do
  alias Merchant.Transactions.Disbursement

  defmacro __using__(_opts) do
    quote do
      def disbursement_factory(attrs) do
        trader = Map.get_lazy(attrs, :trader, fn -> insert(:trader) end)
        today = Timex.today()
        process_date = Timex.shift(today, days: -1)

        disbursement =
          %Disbursement{
            trader: trader,
            reference: Merchant.ReferenceGenerator.from_date(process_date),
            disbursement_date: today,
            amount: Money.new(2_000)
          }

        disbursement
        |> merge_attributes(attrs)
        |> evaluate_lazy_attributes()
      end
    end
  end
end
