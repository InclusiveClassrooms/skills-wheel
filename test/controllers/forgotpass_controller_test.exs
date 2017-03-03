defmodule Skillswheel.ForgotpassControllerTest do
  use Skillswheel.ConnCase, async: false

  import Mock
  alias Skillswheel.RedisCli

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

  test "/forgotpass :: show", %{conn: conn} do
    conn = get conn, forgotpass_path(conn, :show, "s00Rand0m")
    assert html_response(conn, 200) =~ "Hello Reset"
    assert html_response(conn, 200) =~ "s00Rand0m"
  end

  describe "/forgotpass :: update_password" do
    setup do
      RedisCli.flushdb()
    end

    test "No matching hash in database :: redirect: / :: flash: User not in database", %{conn: conn} do
      conn = post conn, forgotpass_path(conn, :update_password, "s00Rand0m"),
        %{"forgotpass" => %{"hash" => "s00Rand0m", "newpass" => %{"password" => "mypass"}}}

      assert redirected_to(conn, 302) =~ "/"
      assert get_flash(conn, :error) == "User not in database"
    end

    # test "Matching hash in database :: redirect: / :: flash", %{conn:, conn} do
    #   RedisCli.set("s00Rand0m", "email@me.com")
    #   conn = post conn, forgotpass_path(conn, :updatepassword, "s00Rand0m"),
    #     %{"forgotpass" => %{"hash" => "s00Random", "newpass" => %{"password" => "mypass"}}}
    #   
    #   assert 
    # end
  end
end

