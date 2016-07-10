
defmodule Pedro.Helpers do

  @moduledoc """
    require Pedro.Helpers, as: H  # the cool way
  """

  @doc """
    Convenience to get environment bits. Avoid all that repetitive
    `Application.get_env( :myapp, :blah, :blah)` noise.
  """
  def env(key, default \\ nil), do: env(:pedro, key, default)
  def env(app, key, default), do: Application.get_env(app, key, default)

  @doc """
    Spit to output any passed variable, with location information.
  """
  defmacro spit(obj \\ "", inspect_opts \\ []) do
    quote do
      %{file: file, line: line} = __ENV__
      name = Process.info(self)[:registered_name]
      chain = [ :bright, :red, "\n\n#{file}:#{line}",
                :normal, "\n     #{inspect self}", :green," #{name}"]

      msg = inspect(unquote(obj),unquote(inspect_opts))

      chain = if String.length(msg) > 2,
        do: chain ++ [:red, "\n\n#{msg}"],
        else: chain

      # chain = chain ++ [:yellow, "\n\n#{inspect Process.info(self)}"]

      (chain ++ ["\n\n", :reset]) |> IO.ANSI.format(true) |> IO.puts

      unquote(obj)
    end
  end

  @doc """
    Print to stdout a _TODO_ message, with location information.
  """
  defmacro todo(msg \\ "") do
    quote do
      %{file: file, line: line} = __ENV__
      [ :yellow, "\nTODO: #{file}:#{line} #{unquote(msg)}\n", :reset]
      |> IO.ANSI.format(true)
      |> IO.puts
      :todo
    end
  end

  @doc """
    Apply given defaults to given Keyword. Returns merged Keyword.

    The inverse of `Keyword.merge`, best suited to apply some defaults in a
    chainable way.

    Ex:
      kw = gather_data
        |> transform_data
        |> H.defaults(k1: 1234, k2: 5768)
        |> here_i_need_defaults

    Instead of:
      kw1 = gather_data
        |> transform_data
      kw = [k1: 1234, k2: 5768]
        |> Keyword.merge(kw1)
        |> here_i_need_defaults

      iex> [a: 3] |> Pedro.Helpers.defaults(a: 4, b: 5)
      [b: 5, a: 3]
      iex> %{a: 3} |> Pedro.Helpers.defaults(%{a: 4, b: 5})
      %{a: 3, b: 5}

  """
  def defaults(args, defs) when is_map(args) and is_map(defs) do
    defs |> Map.merge(args)
  end
  def defaults(args, defs) do
    if not([Keyword.keyword?(args), Keyword.keyword?(defs)] === [true, true]),
      do: raise(ArgumentError, "Both arguments must be Keyword lists.")
    defs |> Keyword.merge(args)
  end

  @doc """
    Raise an error if any given key is not in the given Keyword.
    Returns given Keyword, so it can be chained using pipes.
  """
  def requires(args, required) do
    keys = args |> Keyword.keys
    for r <- required do
      if not r in keys do
        raise ArgumentError, message: "Required argument '#{r}' was not present in #{inspect(args)}"
      end
    end
    args # chainable
  end

  @doc """
    Get timestamp in seconds, microseconds, or nanoseconds
  """
  def ts(scale \\ :seconds) do
    {mega, sec, micro} = :os.timestamp
    t = mega * 1_000_000 + sec
    case scale do
      :seconds -> t
      :micro -> t * 1_000_000 + micro
      :nano -> (t * 1_000_000 + micro) * 1_000
    end
  end

end
