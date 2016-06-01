require Pedro.Helpers, as: H

defmodule Pedro.Mnesia do

  def init() do
    case :mnesia.create_schema([node()]) do
      :ok -> :ok
      {:error, {_, {:already_exists, _}}} -> :ok
      any -> raise "Error initialising mnesia: #{inspect any}"
    end

    :mnesia.start
  end

  def create_table(name, opts \\ []) when is_atom(name) do
    opts = opts
      |> H.requires([:attributes])
      |> H.defaults(disc_copies: [node()])

    :mnesia.create_table(name, opts)
  end

end
