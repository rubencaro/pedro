defmodule Pedro.PingController do
  use Pedro.Web, :controller

  def ping(conn, _params) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Pong")
  end
end
