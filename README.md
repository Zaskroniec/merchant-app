# Merchant app

## Requirements

* Elixir v1.15+
* Erlang 26.1+
* PostgreSQL 15.3+

## How to run
1. Make sure you have the same DB config for postgres [config](/config/dev.exs) 
1. Run `mix ecto.setup && MIX_ENV=test mix ecto.setup`
1. Make sure all tests pass `mix test`
1. Verify code running static analysis `mix quality`
1. Start application by running `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
## Endpoints

Request:

```bash
curl -X POST -H "Content-Type: application/json" -d '{"merchant_reference": "test_reference", "data": {"guid": "test_guid", "amount": {"amount": 10, "currency": "eur"}}}' http://localhost:4000/orders
```

Response:

```json
{
  "data": {
    "amount": {
      "currency":"EUR",
      "amount":10
    },
    "merchant_reference":"padberg_group",
    "guid":"test_guid",
    "created_at":"2024-02-01"
  }
}
```

## Importer

```elixir
# Import traders data (merchants)
Merchant.Imports.Importer.import("/samples/merchants.csv", :traders)

# Import orders data. Depend on the data from traders import
Merchant.Imports.Importer.import("/samples/orders.csv", :orders)
```

## Sync commissions on whole dataset after import

```elixir
# Date is qual to the oldest order created_at column. "historic" => "true" triggers recursive process
# to next operation cycle. This task is also used in Crontab without `historic` param
%{"date" => "2022-09-05", "historic" => "true"} |> Merchant.Transactions.Workers.TradersDisbursements.new |> Oban.insert()
```

## Notes

### Structures

I have decided to use native IDs in the application as primary keys instead of guid from the CSV. I treat them as external identification.

Due to the fact that I have given 'Merchant' as the main module name, I had to change the naming convention from the CSV to 'Trader'. :).

I would also suggest a different name for the structure `Merchant.Transactions.Disbursement`. It may not be the best choice. I would probably change it to `Merchant.Transactions.MonthlyFee`. 

### References

I have choosed very optimistic way of implementing references in the application. In the real scenario I'd rather create dedicated table to store references and then use them to fill `order.disbursement_reference` or `disbursement.reference`
to make sure references are truly unique on database level.

### Workers

I have choosed to split process into two sections. One worker [TradersDisbursements](/lib/merchant/transactions/workers/traders_disbursements.ex) to schedule "smaller" [TraderDisbursements](lib/merchant/transactions/workers/trader_disbursements.ex) processes per tenat (trader - merchant) to calculate commissions and disbursements.

The way the `historic` option works is quite controversial because I iterate over all days starting from the given date in the job parameter. It could be done better, for example, by checking each time which order for the trader is next from the DB point. However, I have chosen a `quicker` solution to implement functionality to cover historical data.

### Impoter

Even though task description didn't mention anything about the data itself in the CSV, I have decided to implement additional check to prevent importing corrupted data. Overall import took ~49/56 secs to process all orders on my local machine.

### Assumptions

My assumptions regarding data related in Statistics:

- Year - nothing to add
- Number of disbursements - aggregation of disbursements based on unique `order.disbursement_reference` per year
- Amount disbursed to merchants - sum aggregation of `order.amount.amount` without difference with `Amount of order fees` per year
- Amount of order fees - sum aggregation of `order.commission_fee.amount` per year
- Number of monthly fees charged (From minimum monthly fee) - count aggregation of `disbursement.reference` per year
- Amount of monthly fee charged (From minimum monthly fee) - sum aggregation of `disbursement.amount.amount` per year

The fact is that the overall `Number of monthly fees` charged is quite low. My approach was that whenever `trader.minimum_monthly_fee` is equal to 0, then a `disbursement` row was not created, because `max(0, trader.minimum_monthly_fee - monthly_commissions)` was always 0.

## Statistics

| Year | Number of disbursements | Amount disbursed to merchants | Amount of order fees | Number of monthly fees charged (From minimum monthly fee) | Amount of monthly fee charged (From minimum monthly fee) |
|----------|----------|----------|----------|----------|----------|
| 2022   | 13_365   | 189,317,115.60 €   | 1,700,710.40 €  | 120   | 2,048.25 €   |
| 2023   | 2_131   | 38,219,742.31 €   | 342,227.73 €   | 30   | 536.76 €   |
