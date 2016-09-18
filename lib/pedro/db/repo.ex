require Pedro.Helpers, as: H

defmodule Pedro.Db.Repo do

  @moduledoc """
  Helpers to interact with Mnesia in single node mode.
  """

  @tables [Pedro.Db.EntryQueue, Pedro.Db.Messages, Pedro.Db.Throttles]

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

  # Use `:ets.fun2ms` to get the spec
  def select(table, spec) do
    table
    |> :mnesia.select(spec)
    |> Enum.map(&(record2struct(table, &1)))
  end

  # Use `:ets.fun2ms` to get the spec
  def dirty_select(table, spec) do
    table
    |> :mnesia.dirty_select(spec)
    |> Enum.map(&(record2struct(table, &1)))
  end

  # :ets.fun2ms(fn(x)-> x end)
  def all(table), do: select(table, [{:"$1", [], [:"$1"]}])

  def dirty_all(table), do: dirty_select(table, [{:"$1", [], [:"$1"]}])

  def write(struct) when is_map(struct) do
    struct |> struct2record |> :mnesia.write
  end

  def dirty_write(struct) when is_map(struct) do
    struct |> struct2record |> :mnesia.dirty_write
  end

  defp struct2record(struct) do
    module = struct.__struct__
    struct
    |> Map.from_struct  # remove struct's name
    |> Map.values
    |> List.insert_at(0, module)
    |> List.to_tuple
  end

  defp record2struct(module, record) do
    module
    |> module2attributes
    |> List.insert_at(0, :__struct__)
    |> Enum.zip(Tuple.to_list(record))  # zip struct's keys with record's values
    |> attributes2struct(module)
  end

  def module2attributes(module) do
    module.__struct__  # an empty struct
    |> Map.from_struct  # remove struct's name
    |> Map.keys
  end

  defp attributes2struct(attributes, module) do
    attributes
    |> List.insert_at(0, {:__struct__, module})  # add struct's name
    |> Enum.into(%{})  # to struct
  end

end
