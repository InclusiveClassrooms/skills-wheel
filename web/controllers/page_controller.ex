defmodule Skillswheel.PageController do
  @moduledoc false
  use Skillswheel.Web, :controller

  def index(conn, _params) do
    if conn.assigns.current_user do
      conn
      |> redirect(to: group_path(conn, :index))
    else
      conn
      |> redirect(to: session_path(conn, :new))
    end
  end
end
