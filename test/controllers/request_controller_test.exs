require Pedro.Helpers, as: H  # the cool way

defmodule Pedro.RequestControllerTest do
  use Pedro.ConnCase, async: true
  import Pedro.TestTools

  test "POST /request validates signature" do
    conn = build_conn()
    |> put_req_header("content-type", "application/json")
    |> post("/request", Poison.encode!(%{any: "thing"}))
    assert response(conn, 401) == "unauthorized"
  end

  test "GET /request validates signature" do
    conn = get build_conn(), "/request?#{URI.encode_query(%{any: "thing"})}"
    assert response(conn, 401) == "unauthorized"
  end

  test "POST /request" do
    in_test_transaction do
      input = %{WIP: true, message: "work in progress"}


      conn = signed_post build_conn(), "/request", input
      data = assert_valid_json(conn)
      assert %{"valid" => true, "request" => %{"WIP" => true, "message" => "work in progress"}} = data

      H.spit :mnesia.all_keys(Pedro.Db.EntryQueue)

      H.todo "Test actual db interaction"
    end
  end

  test "GET /request" do
    in_test_transaction do
      input = %{WIP: true, message: "work in progress"}

      conn = signed_get build_conn(), "/request", input
      data = assert_valid_json(conn)
      assert %{"valid" => true, "request" => %{"WIP" => "true", "message" => "work in progress"}} = data

      H.todo "Test actual db interaction"
    end
  end
end
