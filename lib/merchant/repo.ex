defmodule Merchant.Repo do
  use Ecto.Repo,
    otp_app: :merchant,
    adapter: Ecto.Adapters.Postgres
end
