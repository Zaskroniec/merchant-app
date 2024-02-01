defmodule Merchant.Factory do
  use ExMachina.Ecto, repo: Merchant.Repo

  use Merchant.Factories.Trader
  use Merchant.Factories.Order
end
