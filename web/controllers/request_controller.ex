require Pedro.Helpers, as: H  # the cool way

defmodule Pedro.RequestController do
  use Pedro.Web, :controller

  def request(conn, params) do
    res = %{valid: true, request: params}
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, res |> Poison.encode!)
  end
end
