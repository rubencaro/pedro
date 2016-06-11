require Pedro.Helpers, as: H

defmodule Pedro.Mnesia do

  @moduledoc """
  Helpers to interact with Mnesia in single node mode.
  """

  @doc """
  create_schema and then start Mnesia in single node mode

  Returns `:ok` or `{:error, reason}`
  """
  def init() do
    create_schema
    |> start_mnesia
    |> create_all_tables
  end

  defp create_schema do
    case :mnesia.create_schema([node()]) do
      :ok -> :ok
      {:error, {_, {:already_exists, _}}} -> :ok
      any -> any
    end
  end

  defp start_mnesia(:ok), do: :mnesia.start
  defp start_mnesia(any), do: any  # error piping

  defp create_all_tables(:ok) do

    results = tables_definition |> Enum.map(&create_table/1)

    case Enum.all?(results, &(match?(:ok,&1))) do
      true -> :ok
      false -> {:error, results}
    end
  end
  defp create_all_tables(any), do: any  # error piping

  defp create_table([name: name, opts: opts]) when is_atom(name) do
    opts = opts
      |> H.requires([:attributes])
      |> H.defaults(disc_copies: [node()])

    case :mnesia.create_table(name, opts) do
      {:ok, :atomic} -> :ok
      {:aborted, {:already_exists, _}} -> :ok
      {:aborted, reason} -> {:error, reason}
    end
  end

  defp tables_definition do
    [
      [name: Pedro.EntryQueue, opts: [attributes: [:id, :received_ts, :target_ts, :adapter, :options, :json_payload]]],
      [name: Pedro.Messages,   opts: [attributes: [:id, :received_ts, :target_ts, :deliver_ts, :json_payload]]],
      [name: Pedro.Throttles,  opts: [attributes: [:key, :since_ts, :consumed, :period]]]
    ]
  end
end
