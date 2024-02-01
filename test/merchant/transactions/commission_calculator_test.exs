defmodule Merchant.Transactions.CommissionCalculatorTest do
  use Merchant.DataCase, async: true

  alias Merchant.Transactions.CommissionCalculator

  describe "calculate/1" do
    test "calculate commission for amount less than 5,000" do
      amount = %Money{amount: 4_000, currency: :EUR}

      assert %Money{amount: 40, currency: :EUR} = CommissionCalculator.calculate(amount)
    end

    test "calculate commission for amount between 5,000 and 30,000" do
      amount = %Money{amount: 15_000, currency: :EUR}

      assert %Money{amount: 143, currency: :EUR} = CommissionCalculator.calculate(amount)
    end

    test "calculate commission for amount greater than or equal to 30,000" do
      amount = %Money{amount: 35_000, currency: :EUR}

      assert %Money{amount: 298, currency: :EUR} = CommissionCalculator.calculate(amount)
    end
  end
end
