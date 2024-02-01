defmodule Merchant.Transactions.Workers.TraderDisbursementsTest do
  use Merchant.DataCase, async: true

  alias Merchant.Repo
  alias Merchant.Transactions.Disbursement
  alias Merchant.Transactions.Order
  alias Merchant.Transactions.Workers.TraderDisbursements

  describe "perform/1" do
    test "creates commission on orders for a trader with :weekly frequency on a specific date" do
      date_of_process = ~D[2024-01-31]
      date_for_disbursements = Timex.shift(date_of_process, days: -1)
      trader = insert(:trader, disbursement_frequency: :weekly, live_on: ~D[2024-01-24])

      [%{id: ord_1_id}, %{id: ord_2_id}] =
        insert_list(2, :order, trader: trader, created_at: date_for_disbursements)

      %{id: skipped_ord_id} = insert(:order, trader: trader, created_at: ~D[2024-01-22])

      job = %Oban.Job{
        args: %{
          "trader_id" => trader.id,
          "date" => Date.to_string(date_of_process),
          "historic" => "false"
        }
      }

      assert :ok = TraderDisbursements.perform(job)

      orders =
        Order
        |> Repo.all()
        |> Enum.sort_by(& &1.id)

      assert [
               %Order{
                 id: ^ord_1_id,
                 disbursement_reference: disbursement_reference_1,
                 disbursement_date: ^date_of_process,
                 commission_fee: %Money{amount: 10, currency: :EUR}
               },
               %Order{
                 id: ^ord_2_id,
                 disbursement_reference: disbursement_reference_2,
                 disbursement_date: ^date_of_process,
                 commission_fee: %Money{amount: 10, currency: :EUR}
               },
               %Order{
                 id: ^skipped_ord_id,
                 disbursement_reference: nil,
                 disbursement_date: nil,
                 commission_fee: nil
               }
             ] = orders

      refute is_nil(disbursement_reference_1)
      refute is_nil(disbursement_reference_2)
    end

    test "creates commission on orders for a trader on a specific date" do
      date_of_process = ~D[2024-01-31]
      date_for_disbursements = Timex.shift(date_of_process, days: -1)
      trader = insert(:trader)

      [%{id: ord_1_id}, %{id: ord_2_id}] =
        orders = insert_list(2, :order, trader: trader, created_at: date_for_disbursements)

      job = %Oban.Job{
        args: %{
          "trader_id" => trader.id,
          "date" => Date.to_string(date_of_process),
          "historic" => "false"
        }
      }

      assert :ok = TraderDisbursements.perform(job)

      orders =
        orders
        |> Repo.reload()
        |> Enum.sort_by(& &1.id)

      assert [
               %Order{
                 id: ^ord_1_id,
                 disbursement_reference: disbursement_reference_1,
                 disbursement_date: ^date_of_process,
                 commission_fee: %Money{amount: 10, currency: :EUR}
               },
               %Order{
                 id: ^ord_2_id,
                 disbursement_reference: disbursement_reference_2,
                 disbursement_date: ^date_of_process,
                 commission_fee: %Money{amount: 10, currency: :EUR}
               }
             ] = orders

      refute is_nil(disbursement_reference_1)
      refute is_nil(disbursement_reference_2)
    end

    test "creates disbursement based on difference betweem minimum_monthly_fee and commission from previous month cycle" do
      date_of_process = ~D[2024-02-02]
      date_for_disbursements = Timex.shift(date_of_process, days: -1)
      previous_month_date = Timex.shift(date_of_process, days: -2)
      trader = insert(:trader)

      _order_from_previous_month =
        insert(:order,
          trader: trader,
          created_at: previous_month_date,
          disbursement_date: previous_month_date,
          disbursement_reference: "xyz",
          commission_fee: %Money{amount: 10, currency: :EUR}
        )

      insert_list(2, :order, trader: trader, created_at: date_for_disbursements)

      job = %Oban.Job{
        args: %{
          "trader_id" => trader.id,
          "date" => Date.to_string(date_of_process),
          "historic" => "false"
        }
      }

      assert :ok = TraderDisbursements.perform(job)

      assert [
               %{
                 amount: %Money{amount: 1490, currency: :EUR},
                 disbursement_date: ~D[2024-01-01],
                 reference: "2024_01"
               }
             ] = Repo.all(Disbursement)
    end

    test "does not create disbursement when minimum_monthly_fee is less than
          commission from previous month cycle " do
      date_of_process = ~D[2024-02-02]
      date_for_disbursements = Timex.shift(date_of_process, days: -1)
      previous_month_date = Timex.shift(date_of_process, days: -2)
      trader = insert(:trader, minimum_monthly_fee: Money.new(0))

      _order_from_previous_month =
        insert(:order,
          trader: trader,
          created_at: previous_month_date,
          disbursement_date: previous_month_date,
          disbursement_reference: "xyz",
          commission_fee: %Money{amount: 10, currency: :EUR}
        )

      insert_list(2, :order, trader: trader, created_at: date_for_disbursements)

      job = %Oban.Job{
        args: %{
          "trader_id" => trader.id,
          "date" => Date.to_string(date_of_process),
          "historic" => "false"
        }
      }

      assert :ok = TraderDisbursements.perform(job)

      assert [] = Repo.all(Disbursement)
    end

    test "handles historic orders correctly" do
      past_date = ~D[2024-01-28]
      trader = insert(:trader)

      [%{id: ord_1_id}, %{id: ord_2_id}, %{id: ord_3_id}, %{id: ord_4_id}] =
        orders =
        [
          insert(:order, trader: trader, created_at: ~D[2024-01-27]),
          insert(:order, trader: trader, created_at: ~D[2024-01-28]),
          insert(:order, trader: trader, created_at: ~D[2024-01-29]),
          insert(:order, trader: trader, created_at: ~D[2024-01-30])
        ]

      job = %Oban.Job{
        args: %{
          "trader_id" => trader.id,
          "date" => Date.to_string(past_date),
          "historic" => "true"
        }
      }

      assert :ok = TraderDisbursements.perform(job)

      orders =
        orders
        |> Repo.reload()
        |> Enum.sort_by(& &1.id)

      assert [
               %Order{
                 id: ^ord_1_id,
                 disbursement_reference: disbursement_reference_1,
                 disbursement_date: ~D[2024-01-28],
                 commission_fee: %Money{amount: 10, currency: :EUR}
               },
               %Order{
                 id: ^ord_2_id,
                 disbursement_reference: disbursement_reference_2,
                 disbursement_date: ~D[2024-01-29],
                 commission_fee: %Money{amount: 10, currency: :EUR}
               },
               %Order{
                 id: ^ord_3_id,
                 disbursement_reference: disbursement_reference_3,
                 disbursement_date: ~D[2024-01-30],
                 commission_fee: %Money{amount: 10, currency: :EUR}
               },
               %Order{
                 id: ^ord_4_id,
                 disbursement_reference: disbursement_reference_4,
                 disbursement_date: ~D[2024-01-31],
                 commission_fee: %Money{amount: 10, currency: :EUR}
               }
             ] = orders

      refute is_nil(disbursement_reference_1)
      refute is_nil(disbursement_reference_2)
      refute is_nil(disbursement_reference_3)
      refute is_nil(disbursement_reference_4)
    end
  end
end
