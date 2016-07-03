defmodule Pedro.TestTools do

  @moduledoc """
  Custom assertions and handy functions and macros for testing.
  `import` into your `Case` modules like:

  defmodule Pedro.RequestControllerTest do
    use Pedro.ConnCase, async: true
    import Pedro.TestTools
    ....
  end

  """

  defmacro assert_valid_json(conn) do
    quote do
      data = json_response(unquote(conn), 200)
      assert %{"valid" => true} = data
      data
    end
  end

  @doc """
  `get` with the appropriate sigature from `Cipher`
  """
  defmacro signed_get(conn, url) do
    quote do
      get unquote(conn), Cipher.sign_url(unquote(url))
    end
  end
  defmacro signed_get(conn, path, data) do
    quote do
      signed_get(unquote(conn), "#{unquote(path)}?#{URI.encode_query(unquote(data))}")
    end
  end

  @doc """
  `post` of JSON body with the appropriate sigature from `Cipher`
  """
  defmacro signed_post(conn, url, data) do
    quote do
      input = unquote(data)
      signed_url = Cipher.sign_url_from_mapped_body(unquote(url), input)
      conn = unquote(conn)
      |> put_req_header("content-type", "application/json")
      |> post(signed_url, Poison.encode!(input))
    end
  end

  @doc """
  Run given block inside a `mnesia` transaction.
  Always `abort` the transaction after the block is run.
  No data should be left on the database, and test should be able to run parallel.
  """
  defmacro in_test_transaction(do: block) do
    quote do
      run_in_test_transaction(fn->
        unquote(block)
      end)
    end
  end

  def run_in_test_transaction(fun) do
    # an `Agent` unique for this <pid>_in_test_transaction
    pid = self |> :erlang.pid_to_list |> to_string
    agent = "#{pid}_in_test_transaction" |> String.to_atom
    Agent.start_link(fn -> %{error: nil, throw: nil} end, name: agent)

    :mnesia.transaction(fn ->
      # capture any error, exit or throw and save it for afterwards notification
      try do
        fun.()
      rescue
        x ->
          t = System.stacktrace  # preserve original stacktrace
          Agent.update(agent, &Map.put(&1,:error,%{msg: x, trace: t}))
      catch
        x ->
          Agent.update(agent, &Map.put(&1,:throw,x))
      end
      :mnesia.abort(:in_test_transaction)
    end)
    |> raise_if_unexpected

    # reproduce any captured specimen
    %{error: err, throw: thr} = Agent.get(agent, &(&1))
    if err, do: reraise(err.msg,err.trace)
    if thr, do: throw(thr)
  end

  defp raise_if_unexpected(response) do
    case response do
      {:aborted, :in_test_transaction} -> :ok
      x -> raise("Unexpected return value from Mnesia transaction: #{inspect x}")
    end
  end

end
