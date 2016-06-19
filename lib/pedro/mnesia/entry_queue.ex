defmodule Pedro.Mnesia.EntryQueue do

  @moduledoc """
  Helpers to work with the EntryQueue table
  """

  def table_definition do
    [ name: Pedro.Mnesia.EntryQueue,
      opts: [
        attributes: [:id, :received_ts, :target_ts, :adapter, :options, :json_payload]
      ]
    ]
  end

end
