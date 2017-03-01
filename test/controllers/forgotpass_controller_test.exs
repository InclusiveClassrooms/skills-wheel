defmodule Skillswheel.ForgotpassControllerTest do
  use Skillswheel.ConnCase

  test "/forgotpass :: index", %{conn: conn} do
    conn = get conn, forgotpass_path(conn, :index)
    assert html_response(conn, 200) =~ "Forgotten Password"
  end

  test "/forgotpass :: create", %{conn: conn} do
    conn = post conn, forgotpass_path(conn, :create,
      %{"forgotpass" => %{"email" => "email@me.com"}})
    assert redirected_to(conn, 302) =~ "/forgotpass"
  end
end
