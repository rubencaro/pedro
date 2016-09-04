alias Pedro.Db.Messages
require Pedro.Helpers, as: H

defmodule Pedro.InboxControllerTest do
  use Pedro.ConnCase, async: true
  import Pedro.TestTools

  test "POST /inbox/put validates signature" do
    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> post("/inbox/put", Poison.encode!(%{any: "thing"}))
    assert response(conn, 401) == "unauthorized"
  end

  test "GET /inbox/put validates signature" do
    conn = get build_conn(), "/inbox/put?#{URI.encode_query(%{any: "thing"})}"
    assert response(conn, 401) == "unauthorized"
  end

  test "GET /inbox validates signature" do
    conn = get build_conn(), "/inbox?#{URI.encode_query(%{any: "thing"})}"
    assert response(conn, 401) == "unauthorized"
  end

  test "POST /inbox/put" do
    in_test_transaction do
      deserialized_input = post_message %{WIP: true, from: "me", to: "you", message: "work in progress"}

      assert [row] = Messages.all
      assert ^deserialized_input = Poison.decode!(row.json_payload)
    end
  end

  test "GET /inbox/put" do
    in_test_transaction do
      input = %{WIP: "true", from: "me", to: "you", message: "work in progress"}  # booleans on query string come as text!
      deserialized_input = input |> Poison.encode! |> Poison.decode!

      data = build_conn()
        |> signed_get("/inbox/put", input)
        |> assert_valid_json
      assert %{"valid" => true, "request" => ^deserialized_input, "response" => "OK"} = data

      assert [row] = Messages.all
      assert ^deserialized_input = Poison.decode!(row.json_payload)
    end
  end

  test "GET /inbox" do
    in_test_transaction do
      # empty inbox
      req = %{to: "you"}
      deserialized_req = req |> Poison.encode! |> Poison.decode!
      data = build_conn()
        |> signed_get("/inbox", req)
        |> assert_valid_json
      assert %{"valid" => true, "request" => ^deserialized_req, "response" => []} = data

      # put some Messages into the inbox
      assert [] = Messages.all
      post_message %{WIP: true, from: "me", to: "you", message: "work in progress"}
      post_message %{WIP: true, from: "me", to: "you", message: "work in progress"}
      post_message %{WIP: true, from: "me2", to: "you", message: "work in progress"}
      post_message %{WIP: true, from: "me", to: "you2", message: "work in progress"}
      assert [_,_,_,_] = Messages.all

      # gets only messages to: "you"
      data = build_conn()
        |> signed_get("/inbox", req)
        |> assert_valid_json
      assert %{"valid" => true, "request" => ^deserialized_req, "response" => rows} = data

      assert Enum.count(rows) == 3
      assert Enum.all?(rows, fn(r)-> match?(%{"to" => "you"}, r) end)
    end
  end

  defp post_message(input) do
    deserialized_input = input |> Poison.encode! |> Poison.decode!

    data = build_conn()
      |> signed_post("/inbox/put", input)
      |> assert_valid_json

    assert %{"valid" => true, "request" => ^deserialized_input, "response" => "OK"} = data
    deserialized_input
  end
end
