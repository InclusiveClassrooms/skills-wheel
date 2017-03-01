defmodule Skillswheel.ForgotpassController do
  use Skillswheel.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def create(conn, %{"forgotpass" => %{"email" => email}}) do
    Skillswheel.Mailer.deliver_now(x)

    conn
    |> put_flash(:info, "Email Sent")
    |> redirect(to: forgotpass_path(conn, :index))
  end
end
