defmodule Pedro.PingControllerTest do
  use Pedro.ConnCase

  test "GET /ping" do
    conn = get conn(), "/ping"
    assert text_response(conn, 200) =~ "Pong"
  end
end
