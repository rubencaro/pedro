alias Pedro.Db.Repo
alias Pedro.Db.EntryQueue, as: EQ
require Pedro.Helpers, as: H  # the cool way

defmodule Pedro.Db.EntryQueue do

  @moduledoc """
  Helpers to work with the EntryQueue table
  """
  defstruct [:__id__, :received_ts, :target_ts, :adapter, :options, :json_payload]

  def table_definition do
    [name: EQ,
     opts: [attributes: Repo.module2attributes(EQ)]]
  end

  def select(spec), do: Repo.select(EQ, spec)

  def all, do: Repo.all(EQ)

  def insert(request) do
    now = H.ts(:nano)
    %EQ{__id__: now,
        received_ts: now,
        target_ts: now,
        adapter: Pedro.Adapter,
        options: [],
        json_payload: Poison.encode!(request)}
    |> Repo.write
  end

  def payload(row) do
    row.json_payload |> Poison.decode!
  end

end
