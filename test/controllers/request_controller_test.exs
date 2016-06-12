require Pedro.Helpers, as: H  # the cool way

defmodule Pedro.RequestControllerTest do
  use Pedro.ConnCase, async: true
  import Pedro.TestTools

  test "POST /request" do
    in_test_transaction do

      input = %{WIP: true, message: "work in progress"}
      output = %{"valid" => true, "request" => %{"WIP" => true, "message" => "work in progress"}}

      conn = conn()
      |> put_req_header("content-type", "application/json")
      |> post("/request", Poison.encode!(input))
      assert response(conn, 401) == "unauthorized"

      assert ^output = json_response(conn, 200)

    end
  end

  test "GET /request" do
    in_test_transaction do

      input = %{WIP: true, message: "work in progress"}
      output = %{"valid" => true, "request" => %{"WIP" => true, "message" => "work in progress"}}

      conn = get conn(), "/request?#{URI.encode_query(input)}"
      assert response(conn, 401) == "unauthorized"

      conn = signed_get conn(), "/request", input
      assert_valid_json(conn)

      H.todo "Test actual db interaction"

    end
  end
end
