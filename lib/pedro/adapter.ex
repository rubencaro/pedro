defmodule Pedro.Adapter do

  @callback send(String.t, Keyword.t) :: :ok | {:error, String.t}
  @callback send(String.t) :: :ok | {:error, String.t}

end
