require Pedro.Helpers, as: H  # the cool way

defmodule Pedro.Router do
  use Pedro.Web, :router

  pipeline :open do
    plug :accepts, ["html","json"]
  end

  pipeline :signed do
    plug :accepts, ["html","json"]
    plug Pedro.ValidateSignature, error_fun: &Pedro.Router.log_validation_error/2
  end

  scope "/", Pedro do
    pipe_through :open
    get "/ping", PingController, :ping
  end

  scope "/", Pedro do
    pipe_through :signed
    post "/request", RequestController, :request
    get "/request", RequestController, :request
  end

  def log_validation_error(conn, error) do
    H.spit(error)
  end
end
