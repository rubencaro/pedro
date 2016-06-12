defmodule Pedro.TestHelpers do

  @moduledoc """
  Test-time helpers.Use like:

    require Pedro.TestHelpers, as: TH  # the cool way
  """

  @doc """
  Run given block inside a `mnesia` transaction.
  Always `abort` the transaction after the block is run.
  No data should be left on the database, and test should be able to run parallel.
  """
  defmacro in_test_transaction(do: block) do
    quote do
      # an `Agent` unique for this <pid>_in_test_transaction
      pid = self |> :erlang.pid_to_list |> to_string
      agent = "#{pid}_in_test_transaction" |> String.to_atom
      Agent.start_link(fn -> %{error: nil, throw: nil} end, name: agent)

      :mnesia.transaction(fn ->
        # capture any error, exit or throw and save it for afterwards notification
        try do
          unquote(block)
        rescue
          x ->
            t = System.stacktrace  # preserve original stacktrace
            Agent.update(agent, &Map.put(&1,:error,%{msg: x, trace: t}))
        catch
          x -> Agent.update(agent, &Map.put(&1,:throw,x))
        end
        :mnesia.abort(:in_test_transaction)
      end)

      # reproduce any captured specimen
      %{error: err, throw: thr} = Agent.get(agent, &(&1))
      if err, do: reraise(err.msg,err.trace)
      if thr, do: throw(thr)
    end
  end

end

ExUnit.start
