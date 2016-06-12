require Pedro.Helpers, as: H  # the cool way

defmodule Pedro.ValidateSignature do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, opts \\ []) do
    url = "#{conn.request_path}?#{conn.query_string}"

    H.spit conn
    H.spit conn.method

    validation = case conn.method do
      "POST" -> Cipher.validate_signed_body(url)
      "GET"  -> Cipher.validate_signed_url(url)
      any -> Cipher.validate_signed_url(url)
    end

    H.spit validation

    case validation do
      {:ok, _} -> conn

      {:error, error} ->
        # call user fun if given
        if opts[:error_fun], do: opts[:error_fun].(conn, error)

        conn
        |> send_resp(401, "unauthorized")
        |> halt
    end
  end

end
