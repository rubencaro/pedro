require Pedro.TestHelpers, as: TH
require Pedro.Helpers, as: H  # the cool way

defmodule Pedro.RequestControllerTest do
  use Pedro.ConnCase

  test "POST /api/request" do
    TH.in_test_transaction do

      input = [WIP: true, message: "work in progress"]
      output = %{"valid" => true, "request" => %{"WIP" => true, "message" => "work in progress"}}

      conn = post conn(), "/api/request", input

      assert ^output = json_response(conn, 200)
    end
  end
end
