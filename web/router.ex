
defmodule Pedro.Router do
  use Pedro.Web, :router

  pipeline :open do
    plug :accepts, ["html","json"]
  end

  pipeline :signed do
    plug :accepts, ["html","json"]
    plug Cipher.ValidatePlug #, error_callback: &Pedro.Router.log_validation_error/2
  end

  scope "/", Pedro do
    pipe_through :open
    get "/ping", PingController, :ping
  end

  scope "/", Pedro do
    pipe_through :signed
    post "/request", RequestController, :request
    get "/request", RequestController, :request
    post "/inbox/put", InboxController, :put
    get "/inbox/put", InboxController, :put
  end

  # def log_validation_error(conn, error) do
  #   require Pedro.Helpers, as: H  # the cool way
  #   H.spit(error)
  # end
end
