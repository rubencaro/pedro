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
    with :ok <- create_schema,
         :ok <- :mnesia.start,
         true <- create_all_tables,
         do: :ok
  end

  defp create_schema do
    case :mnesia.create_schema([node()]) do
      :ok -> :ok
      {:error, {_, {:already_exists, _}}} -> :ok
      any -> raise "Error initialising mnesia: #{inspect any}"
    end
  end

  defp create_all_tables do
    [
      [name: Pedro.EntryQueue, opts: [attributes: [:id, :received_ts, :target_ts, :adapter, :options, :json_payload]]],
      [name: Pedro.Messages,   opts: [attributes: [:id, :received_ts, :target_ts, :deliver_ts, :json_payload]]],
      [name: Pedro.Throttles,  opts: [attributes: [:key, :since_ts, :consumed, :period]]]
    ]
    |> Enum.map(&create_table/1)
    |> Enum.all?(&(match?({:ok,:atomic},&1)))
  end

  @doc """
  Create a table with given `name` and options.
  `:attributes` are required.

  Returns `{:ok, :atomic}` or `{:aborted, reason}`
  """
  def create_table([name: name, opts: opts]) when is_atom(name) do
    opts = opts
      |> H.requires([:attributes])
      |> H.defaults(disc_copies: [node()])

    :mnesia.create_table(name, opts)
  end

end
