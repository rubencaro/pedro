defmodule Pedro.Adapter do
  @moduledoc """
    Behaviour to ensure every Adapter around is on the same page.
  """

  @callback send(String.t, Keyword.t) :: :ok | {:error, String.t}
  @callback send(String.t) :: :ok | {:error, String.t}

end
