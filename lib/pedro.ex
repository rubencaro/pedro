require Pedro.Helpers, as: H

defmodule Pedro do
  @moduledoc """
    Main application module.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # respond to harakiri restarts
    tmp_path = :tmp_path |> H.env("tmp") |> Path.expand
    Harakiri.add %{paths: ["#{tmp_path}/restart"],
                   action: :restart}, create_paths: true

    :ok = Pedro.Db.Repo.init

    children = [
      supervisor(Pedro.Endpoint, []),
      supervisor(Pedro.Dispatcher.PoolSupervisor, []),
      worker(Task, [Pedro, :alive_loop, [[name: Pedro.AliveLoop]]])
    ]

    opts = [strategy: :one_for_one, name: Pedro.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Pedro.Endpoint.config_change(changed, removed)
    :ok
  end

  @doc """
    Tell the world outside we are alive
  """
  def alive_loop(opts \\ []) do
    # register the name if asked
    if opts[:name], do: Process.register(self,opts[:name])

    :timer.sleep 5_000
    tmp_path = :tmp_path |> H.env("tmp") |> Path.expand
    {_, _, version} = Application.started_applications |> Enum.find(&match?({:pedro, _, _}, &1))
    "echo '#{version}' > #{tmp_path}/alive" |> to_charlist |> :os.cmd
    alive_loop
  end

end
