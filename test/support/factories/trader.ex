defmodule Merchant.Factories.Trader do
  alias Merchant.Transactions.Trader

  defmacro __using__(_opts) do
    quote do
      def trader_factory(attrs) do
        email = Faker.Internet.email()

        trader =
          %Trader{
            email: email,
            guid: Ecto.UUID.generate(),
            reference: Merchant.ReferenceGenerator.from_email(email),
            live_on: Timex.today(),
            disbursement_frequency: Enum.random(Trader.frequencies()),
            minimum_monthly_fee: Money.new(1_500)
          }

        trader
        |> merge_attributes(attrs)
        |> evaluate_lazy_attributes()
      end
    end
  end
end
