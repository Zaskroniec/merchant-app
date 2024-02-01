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

  describe "from_word_date/2" do
    test "generates reference from valid word and date" do
      word = "word"
      date = ~D[2024-01-15]

      assert "word_2024_01_15" = ReferenceGenerator.from_word_date(word, date)
    end

    test "returns error for invalid word and date" do
      word = 1
      date = ~D[2024-01-15]

      assert {:error, :invalid_input} = ReferenceGenerator.from_word_date(word, date)
    end
  end

  describe "from_date/1" do
    test "generates reference from valid date" do
      date = ~D[2024-01-15]

      assert "2024_01" = ReferenceGenerator.from_date(date)
    end

    test "v from invalid date" do
      date = Timex.to_datetime(~D[2024-01-15])

      assert {:error, :invalid_input} = ReferenceGenerator.from_date(date)
    end
  end
end
