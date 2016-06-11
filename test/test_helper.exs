
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
      :mnesia.transaction(fn ->
        unquote(block)
        :mnesia.abort(:in_test_transaction)
      end)
    end
  end

end

ExUnit.start
