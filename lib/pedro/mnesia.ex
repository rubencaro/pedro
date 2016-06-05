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
    case :mnesia.create_schema([node()]) do
      :ok -> :ok
      {:error, {_, {:already_exists, _}}} -> :ok
      any -> raise "Error initialising mnesia: #{inspect any}"
    end

    :mnesia.start
  end

  @doc """
  Create a table with given `name` and options.
  `:attributes` are required.

  Returns `{:ok, :atomic}` or `{:aborted, reason}`
  """
  def create_table(name, opts \\ []) when is_atom(name) do
    opts = opts
      |> H.requires([:attributes])
      |> H.defaults(disc_copies: [node()])

    :mnesia.create_table(name, opts)
  end

end
