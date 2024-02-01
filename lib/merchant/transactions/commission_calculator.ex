defmodule Merchant.Transactions.CommissionCalculator do
  @moduledoc """
  Module resposible for calculating commissions
  """

  @doc """
  Calculate missission for given Money type struct

  ## Examples

      iex> CommissionCalculator.calculate(%Money{amount: 100, currency: :EUR})
      %Money{amount: 1, currency: :EUR}
  """
  @spec calculate(Money.t()) :: Money.t()
  def calculate(%Money{amount: amount, currency: _currency} = money) do
    commission_type = amount |> get_commission_type() |> Decimal.new()

    Money.multiply(money, commission_type)
  end

  defp get_commission_type(amount) when amount < 5_000 do
    "0.01"
  end

  defp get_commission_type(amount) when amount >= 5_000 and amount < 30_000 do
    "0.0095"
  end

  defp get_commission_type(amount) when amount >= 30_000 do
    "0.0085"
  end
end
