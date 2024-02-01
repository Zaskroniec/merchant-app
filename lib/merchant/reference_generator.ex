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
end
