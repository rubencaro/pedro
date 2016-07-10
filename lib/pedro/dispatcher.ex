defmodule Pedro.Dispatcher do
  use GenServer

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts)

  def init(opts), do: {:ok, opts}

end
