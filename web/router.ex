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

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug Skillswheel.Auth, repo: Skillswheel.Repo
  end

  scope "/", Skillswheel do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/users", UserController, only: [:new, :create]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    resources "/admin", AdminController, only: [:index]
    resources "/school", SchoolController, only: [:create, :delete]
    resources "/forgotpass", ForgotpassController, only: [:index, :create, :show]
    post "/forgotpass/:hash", ForgotpassController, :update_password
    resources "/groups", GroupController, only: [:index, :create, :show, :delete, :update]
    resources "/students", StudentController, only: [:create, :show, :delete]
    resources "/survey", SurveyController, only: [:show]
    post "/survey/:student_id", SurveyController, :create_survey
    get "/file/:file_id", StudentController, :get_file
    post "/invite/:group_id", GroupController, :invite
    resources "/usergroup", UserGroupController, only: [:delete]
  end

  scope "/api", Skillswheel do
    pipe_through :api

    post "/file/:survey_id", StudentController, :post_file
  end
end
