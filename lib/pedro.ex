require Pedro.Helpers, as: H

defmodule Pedro do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # respond to harakiri restarts
    tmp_path = H.env(:tmp_path, "tmp") |> Path.expand
    Harakiri.add %{ paths: ["#{tmp_path}/restart"],
                    action: :restart }, create_paths: true

    :ok = Pedro.Mnesia.init

    children = [
      supervisor(Pedro.Endpoint, []),
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

    tmp_path = H.env(:tmp_path, "tmp") |> Path.expand
    :os.cmd 'touch #{tmp_path}/alive'
    :timer.sleep 5_000
    alive_loop
  end
end
