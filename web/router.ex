defmodule Pedro.Router do
  use Pedro.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Pedro  do
    pipe_through :browser
    get "/ping", PingController, :ping
  end

  scope "/api", Pedro do
    pipe_through :api
    post "/request", RequestController, :request
  end
end
