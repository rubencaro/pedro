defmodule Pedro.Router do
  use Pedro.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Pedro do
    pipe_through :api
  end
end
