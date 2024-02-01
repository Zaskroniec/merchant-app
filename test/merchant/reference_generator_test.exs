defmodule Merchant.ReferenceGeneratorTest do
  use Merchant.DataCase, async: true

  alias Merchant.ReferenceGenerator

  describe "from_email/1" do
    test "generates reference from valid email" do
      email = "test.email@example.com"

      assert "example" = ReferenceGenerator.from_email(email)
    end

    test "returns error for invalid email" do
      email = "invalid"

      assert {:error, :invalid_input} = ReferenceGenerator.from_email(email)
    end
  end
end
