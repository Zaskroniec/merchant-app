defmodule Merchant.ReferenceGenerator do
  @moduledoc """
  Module responsible for generating references
  """

  @email_pattern ["@", "."]
  @replace_pattern ["-"]

  @doc """
  Generate reference for given email

  ## Examples

      iex> ReferenceGenerator.from_email("info@test-example.com")
      "test_example"
  """
  @spec from_email(binary()) :: binary() | {:error, atom()}
  def from_email(email) when is_binary(email) do
    email
    |> String.split(@email_pattern)
    |> Enum.reverse()
    |> case do
      [_, domain | _] -> String.replace(domain, @replace_pattern, "_")
      _ -> {:error, :invalid_input}
    end
  end

  def from_email(_email), do: {:error, :invalid_input}

  @doc """
  Generate reference for given binary and date

  ## Examples

      iex> ReferenceGenerator.from_word_date("dummy_word", ~D[2024-12-12])
      "dummy_word_2024_12_12"
  """
  @spec from_word_date(binary(), Date.t()) :: binary() | {:error, atom()}
  def from_word_date(word, date) when is_binary(word) and is_struct(date, Date) do
    date = date |> Date.to_string() |> String.replace(@replace_pattern, "_")

    Enum.join([word, date], "_")
  end

  def from_word_date(_word, _date), do: {:error, :invalid_input}

  @doc """
  Generate reference for given date

  ## Examples

      iex> ReferenceGenerator.from_date("dummy_word", ~D[2024-12-12])
      "2024_12"
  """
  @spec from_date(Date.t()) :: binary() | {:error, atom()}
  def from_date(date) when is_struct(date, Date) do
    [year, month, _] = date |> Date.to_string() |> String.split(@replace_pattern)

    year <> "_" <> month
  end

  def from_date(_date), do: {:error, :invalid_input}
end
