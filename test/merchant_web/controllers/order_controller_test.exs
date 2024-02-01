defmodule MerchantWeb.OrderControllerTest do
  use MerchantWeb.ConnCase

  describe "POST /orders" do
    test "returns status 200 for given params", %{conn: conn} do
      %{reference: reference} = insert(:trader)
      guid = Ecto.UUID.generate()

      params = %{
        "merchant_reference" => reference,
        "data" => %{
          "guid" => guid,
          "amount" => %{amount: 100, currency: "eur"}
        }
      }

      response =
        conn
        |> post("/orders", params)
        |> json_response(200)

      assert %{
               "data" => %{
                 "amount" => %{"amount" => 100, "currency" => "EUR"},
                 "guid" => ^guid,
                 "merchant_reference" => ^reference
               }
             } = response
    end

    test "returns status 404 for invalid trader", %{conn: conn} do
      params = %{
        "merchant_reference" => "test",
        "data" => %{
          "guid" => Ecto.UUID.generate(),
          "amount" => %{amount: 100, currency: "eur"}
        }
      }

      assert_error_sent :not_found, fn ->
        post(conn, "/orders", params)
      end
    end

    test "returns status 422 for invalid params", %{conn: conn} do
      trader = insert(:trader)

      params = %{
        "merchant_reference" => trader.reference,
        "data" => %{
          "amount" => %{amount: 100, currency: "eur"}
        }
      }

      conn = post(conn, "/orders", params)

      assert json_response(conn, 422)
    end
  end
end
