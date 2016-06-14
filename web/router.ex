defmodule Pedro.Router do
  use Pedro.Web, :router

  pipeline :open do
    plug :accepts, ["html","json"]
  end

  pipeline :signed do
    plug :accepts, ["html","json"]
    plug Pedro.ValidateSignature
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
end
