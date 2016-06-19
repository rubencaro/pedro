require Pedro.Helpers, as: H

defmodule Pedro.Mnesia do

  @moduledoc """
  Helpers to interact with Mnesia in single node mode.
  """

  @tables [Pedro.Mnesia.EntryQueue, Pedro.Mnesia.Messages, Pedro.Mnesia.Throttles]

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

    results = @tables
      |> Enum.map(&(apply(&1, :table_definition, [])))
      |> Enum.map(&create_table/1)

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
      {:atomic, :ok} -> :ok
      {:aborted, {:already_exists, _}} -> :ok
      {:aborted, reason} -> {:error, reason}
    end
  end

  def read(table, key) do
    :mnesia.read({table, key})
  end
end
