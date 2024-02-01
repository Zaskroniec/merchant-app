defmodule Merchant.Imports.Importer do
  @moduledoc """
  Module resposible for loading data for given CSV file. Currently supported only
  Order and Trade struct.
  """

  alias Merchant.Imports.Queries
  alias Merchant.Repo
  alias Merchant.Transactions.Order
  alias Merchant.Transactions.Trader

  require Logger

  @csv_options [headers: true, separator: ?;]
  @batch_size 500

  @doc """
  Persist Order or Trader structs in batches. If any error occures during persistance
  they will be ignored.

  ## Examples

      iex> Impoter.import("/path/file.csv", :traders)
      :ok
  """
  @spec import(binary(), atom()) :: :ok
  def import(file_path, resource_name) do
    start_time = Timex.now()
    path = File.cwd!() <> file_path
    {conflict_key, module_name, cached_data} = get_resource_details(resource_name)

    Logger.info("Starting import ...")

    path
    |> File.stream!()
    |> CSV.decode!(@csv_options)
    |> Stream.chunk_every(@batch_size)
    |> Flow.from_enumerable(max_demand: 8)
    |> Flow.partition(max_demand: 8, stages: 8)
    |> Flow.map(fn rows ->
      dataset = build_dataset(rows, cached_data, module_name)

      Repo.insert_all(
        module_name,
        dataset,
        on_conflict: :nothing,
        conflict_target: conflict_key
      )
    end)
    |> Flow.reduce(fn -> [] end, fn item, list -> [item | list] end)
    |> Flow.run()

    execution_time = Timex.diff(Timex.now(), start_time, :millisecond)

    Logger.info("Finished import in: #{execution_time}")

    :ok
  end

  defp get_resource_details(:traders), do: {:reference, Trader, %{}}
  defp get_resource_details(:orders), do: {:guid, Order, Queries.Trader.map_ids_by_references()}

  defp build_dataset(rows, cached_data, module_name) do
    rows
    |> Enum.map(fn row ->
      row
      |> filter_values()
      |> build_params(cached_data, module_name)
      |> module_name.import_changeset()
    end)
    |> Enum.filter(& &1.valid?)
    |> Enum.map(& &1.changes)
  end

  defp filter_values(row) do
    row
    |> Enum.filter(fn {_k, v} -> v != "" end)
    |> Enum.map(fn {k, v} -> {k, HtmlSanitizeEx.strip_tags(v)} end)
    |> Enum.into(%{})
  end

  defp build_params(row, _cached_data, Trader) do
    %{
      guid: row["id"],
      reference: row["reference"],
      email: row["email"],
      live_on: row["live_on"],
      disbursement_frequency: normalize_field(row["disbursement_frequency"]),
      minimum_monthly_fee: normalize_money(row["minimum_monthly_fee"])
    }
  end

  defp build_params(row, cached_data, Order) do
    %{
      guid: row["id"],
      trader_reference: row["merchant_reference"],
      amount: normalize_money(row["amount"]),
      created_at: row["created_at"],
      trader_id: cached_data[row["merchant_reference"]]
    }
  end

  defp normalize_field(nil), do: nil

  defp normalize_field(field) do
    field |> String.trim() |> String.downcase()
  end

  defp normalize_money(nil), do: nil

  defp normalize_money(field) do
    try do
      field |> Decimal.new() |> Money.parse!()
    catch
      _, _ -> nil
    end
  end
end
