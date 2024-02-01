defmodule MerchantWeb.FallbackController do
  use Phoenix.Controller

  def call(conn, {:error, :unprocessable_entity}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: MerchantWeb.ErrorJSON)
    |> render(:"422")
  end
end
