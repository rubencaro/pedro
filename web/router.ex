defmodule Pedro.Router do
  use Pedro.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :browser
    get "/ping", Pedro.PingController, :ping
  end

  scope "/api", Pedro do
    pipe_through :api
  end
end
