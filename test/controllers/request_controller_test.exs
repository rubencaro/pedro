require Pedro.Helpers, as: H  # the cool way

defmodule Pedro.RequestControllerTest do
  use Pedro.ConnCase, async: true
  import Pedro.TestTools

  test "POST /request" do
    in_test_transaction do
      input = %{WIP: true, message: "work in progress"}

      conn = conn()
      |> put_req_header("content-type", "application/json")
      |> post("/request", Poison.encode!(input))
      assert response(conn, 401) == "unauthorized"

      conn = signed_post conn(), "/request", input
      data = assert_valid_json(conn)
      assert %{"valid" => true, "request" => %{"WIP" => true, "message" => "work in progress"}} = data

      H.todo "Test actual db interaction"
    end
  end

  test "GET /request" do
    in_test_transaction do
      input = %{WIP: true, message: "work in progress"}

      conn = get conn(), "/request?#{URI.encode_query(input)}"
      assert response(conn, 401) == "unauthorized"

      conn = signed_get conn(), "/request", input
      data = assert_valid_json(conn)
      assert %{"valid" => true, "request" => %{"WIP" => "true", "message" => "work in progress"}} = data

      H.todo "Test actual db interaction"
    end
  end
end
