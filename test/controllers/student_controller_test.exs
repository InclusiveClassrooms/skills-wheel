defmodule Skillswheel.StudentControllerTest do
  use Skillswheel.ConnCase
  import Mock

  alias Skillswheel.{User, RedisCli}

  test "create new student", %{conn: conn} do
    insert_group()

    conn = post conn, student_path(conn, :create,
      %{"student" => %{
        first_name: "First",
        last_name: "Last",
        sex: "male",
        year_group: "1",
        group_id: 1
      }})
    assert redirected_to(conn, 302) =~ "/groups"
  end

  test "create new student error", %{conn: conn} do
    insert_group()

    conn = post conn, student_path(conn, :create,
      %{"student" => %{
        first_name: "",
        last_name: "",
        sex: "male",
        year_group: "1",
        group_id: 1
      }})
    assert redirected_to(conn, 302) =~ "/groups"
  end

  test "show student", %{conn: conn} do
    insert_user(%{admin: true})
    insert_group()
    insert_usergroup()
    insert_student()
    insert_survey()

    conn =
      conn
      |> assign(:current_user, Repo.get(User, 1))

    conn = get conn, student_path(conn, :show, 1)
    assert html_response(conn, 200) =~ "First"
  end

  test "show student unauthorised", %{conn: conn} do
    insert_user()
    insert_group()
    insert_group(%{id: 2, name: "Test Group 2"})
    insert_usergroup()
    insert_student()
    insert_student(%{id: 2, group_id: 2})

    conn =
      conn
      |> assign(:current_user, Repo.get(User, 1))

    conn = get conn, student_path(conn, :show, 2)
    assert redirected_to(conn, 302) =~ "/groups"
  end

  test "show student non-existent", %{conn: conn} do
    insert_user()

    conn = assign(conn, :current_user, Repo.get(User, 1))
    conn = get conn, student_path(conn, :show, 100)

    assert redirected_to(conn, 302) =~ "/groups"
  end

  describe "downloading a pdf" do
    setup do
      RedisCli.flushdb()
      insert_user()
      insert_group()
      insert_usergroup()
      insert_student()
      insert_survey(%{id: 1})

      :ok
    end

    test "/api/file/:survey_id :: POST", %{conn: conn} do
      with_mock PdfGenerator, [generate_binary!: fn(string, _page_size) -> string end] do
        conn = post conn, student_path(conn, :post_file, "1"),
          %{"_json" => "html"}
        assert json_response(conn, 200) =~ "{\"link\": \"skills_wheel_"
      end
    end

    test "/file/:file_id :: GET - where file exists", %{conn: conn} do
      with_mock PdfGenerator, [generate_binary!: fn(string) -> string end] do
        RedisCli.set("skills_wheel_Rand00mString.pdf", "asdfasdf")
        conn = get conn, student_path(conn, :get_file, "skills_wheel_Rand00mString.pdf")
        assert response(conn, 200) =~ "asdfasdf"
      end
    end

    test "/file/:file_id :: GET - where file doesn't exists", %{conn: conn} do
      with_mock PdfGenerator, [generate_binary!: fn(string) -> string end] do
        conn = get conn, student_path(conn, :get_file, "skills_wheel_doesntexist.pdf")
        assert response(conn, 200) =~ "<html><body><h1> Download Link has Expired </h1><h3> Please try again </h3></body></html>"
      end
    end
  end
end
