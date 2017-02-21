defmodule Skillswheel.PageController do
  use Skillswheel.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
