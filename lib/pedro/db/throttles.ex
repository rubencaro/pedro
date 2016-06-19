defmodule Pedro.Db.Throttles do

  @moduledoc """
  Helpers to work with the Throttles table
  """

  def table_definition do
    [ name: Pedro.Db.Throttles,
      opts: [
        attributes: [:key, :since_ts, :consumed, :period]
      ]
    ]
  end

end
