require Logger

defmodule Pedro.RequestController do
  use Pedro.Web, :controller

  def request(conn, params) do
    res = generate_response(params)
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, res |> Poison.encode!)
  end

  defp generate_response(params) do
    request = params |> Map.drop(["signature"])

    case Pedro.Db.EntryQueue.insert(request) do
      :ok -> %{valid: true, request: request, response: "OK"}
      {:error, reason} ->
        Logger.info("EntryQueue insert failed. request: #{inspect request}, reason: #{inspect reason}")
        %{valid: false, request: request, response: "Something failed. Try again later."}
    end
  end
end
