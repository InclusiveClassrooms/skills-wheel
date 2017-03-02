defmodule Skillswheel.ForgotpassController do
  use Skillswheel.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def create(conn, %{"forgotpass" => %{"email" => email}}) do
    rand_string = gen_rand_string(30)

    email
    |> Skillswheel.Email.forgotten_password_email()
    |> Skillswheel.Mailer.deliver_now()

    conn
    |> put_flash(:info, "Email Sent")
    |> redirect(to: forgotpass_path(conn, :index))
  end

  defp gen_rand_string(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> binary_part(0, length)
  end
end
