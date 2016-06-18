require Pedro.Helpers, as: H  # the cool way

defmodule Pedro.ValidateSignature do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, opts \\ []) do
    url = "#{conn.request_path}?#{conn.query_string}"

    validation = case conn.method do
      "GET"  -> Cipher.validate_signed_url(url)

      # here body is already parsed by `Plug.Parsers`
      # hence we need the signature to be done using `Cipher.sign_url_from_mapped_body`
      "POST" -> Cipher.validate_signed_body(url, conn.body_params)

      any -> Cipher.validate_signed_url(url)
    end

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
