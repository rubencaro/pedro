require Logger
alias Pedro.Db.Messages

defmodule Pedro.InboxController do
  use Pedro.Web, :controller

  def inbox(conn, params) do
    res = generate_inbox_response(params)
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, res |> Poison.encode!)
  end

  defp generate_inbox_response(params) do
    request = params |> Map.drop(["signature"])

    %{valid: true, request: request, response: Messages.to(params["to"])}
  end

  def put(conn, params) do
    res = generate_put_response(params)
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, res |> Poison.encode!)
  end

  defp generate_put_response(params) do
    request = params |> Map.drop(["signature"])

    case Messages.insert(request) do
      :ok -> %{valid: true, request: request, response: "OK"}
      {:error, reason} ->
        Logger.info("Messages insert failed. request: #{inspect request}, reason: #{inspect reason}")
        %{valid: false, request: request, response: "Something failed. Try again later."}
    end
  end
end
