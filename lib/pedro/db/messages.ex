defmodule Pedro.Db.Messages do

  @moduledoc """
  Helpers to work with the Messages table
  """

  def table_definition do
    [ name: Pedro.Db.Messages,
      opts: [
        attributes: [:id, :received_ts, :target_ts, :deliver_ts, :json_payload]
      ]
    ]
  end

end
