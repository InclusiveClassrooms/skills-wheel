defmodule Skillswheel.ForgotpassControllerTest do
  use Skillswheel.ConnCase, async: false

  import Mock

  test "/forgotpass :: index", %{conn: conn} do
    conn = get conn, forgotpass_path(conn, :index)
    assert html_response(conn, 200) =~ "Forgotten Password"
  end

  test "/forgotpass :: create", %{conn: conn} do
    with_mock Skillswheel.Mailer, [deliver_now: fn(_) -> nil end] do
      conn = post conn, forgotpass_path(conn, :create,
        %{"forgotpass" => %{"email" => "sehouston3@gmail.com"}})
      assert redirected_to(conn, 302) =~ "/forgotpass"
    end
  end
end

