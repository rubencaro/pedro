require Pedro.Helpers, as: H  # the cool way

defmodule Pedro.Dispatcher.PoolSupervisor do
  @moduledoc """
    Supervisor for all dispatcher pools out there.
  """
  use Supervisor

  def start_link, do: Supervisor.start_link(__MODULE__, [], [name: __MODULE__])

  def init([]) do
    H.env(:dispatcher)[:pools]
    |> Enum.map(fn(acc) ->
      pool_opts = [worker_module: Pedro.Dispatcher] ++ acc[:pool_opts]
      :poolboy.child_spec(acc[:name], pool_opts, acc[:worker_opts])
    end)
    |> supervise(strategy: :one_for_one)
  end
end
