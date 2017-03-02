defmodule Skillswheel.Router do
  use Skillswheel.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Skillswheel.Auth, repo: Skillswheel.Repo
  end

  # pipeline :api do
  #   plug :accepts, ["json"]
  # end

  scope "/", Skillswheel do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/users", UserController, only: [:new, :create]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    resources "/admin", AdminController, only: [:index]
    resources "/school", SchoolController, only: [:create, :delete]
    resources "/forgotpass", ForgotpassController, only: [:index, :create]
    resources "/groups", GroupController, only: [:index, :create, :show, :delete]
  end

  # Other scopes may use custom stacks.
  # scope "/api", Skillswheel do
  #   pipe_through :api
  # end
end
