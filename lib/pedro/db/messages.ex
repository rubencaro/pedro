alias Pedro.Db.Repo
alias Pedro.Db.Messages
require Pedro.Helpers, as: H  # the cool way

defmodule Pedro.Db.Messages do

  @moduledoc """
  Helpers to work with the Messages table
  """
  defstruct [:__id__, :from, :to, :received_ts, :target_ts, :deliver_ts, :json_payload]

  def table_definition do
    [ name: Messages,
      opts: [ attributes: Repo.module2attributes(Messages) ] ]
  end

  def select(spec), do: Repo.select(Messages, spec)

  # :ets.fun2ms(fn(x = {_, _, _, _, _, _, _, who})-> x end)
  def to(who),
    do: select([{{:_, :_, :_, :_, :_, :_, :_, who}, [], [:"$_"]}])

  def all, do: Repo.all(Messages)

  def insert(request) do
    now = H.ts(:nano)
    %Messages{ __id__: now,
         received_ts: now,
         target_ts: now,
         deliver_ts: now,
         from: request["from"],
         to: request["to"],
         json_payload: Poison.encode!(request) }
    |> Repo.write
  end

  def payload(row) do
    row.json_payload |> Poison.decode!
  end

end
