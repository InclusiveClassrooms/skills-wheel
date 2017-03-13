defmodule Skillswheel.StudentControllerTest do
  use Skillswheel.ConnCase
  import Mock

  alias Skillswheel.{Group, Student, User, UserGroup, Survey, RedisCli}

  test "create new student", %{conn: conn} do
    %Group{
      name: "Test Group 1",
      id: 1
    } |> Repo.insert

    conn = post conn, student_path(conn, :create,
    %{"student" => %{
        first_name: "First",
        last_name: "Last",
        sex: "male",
        year_group: "5",
        group_id: 1
      }})
    assert redirected_to(conn, 302) =~ "/groups"
  end

  test "create new student error", %{conn: conn} do
    %Group{
      name: "Test Group 5",
      id: 5
    } |> Repo.insert

    conn = post conn, student_path(conn, :create,
    %{"student" => %{
        first_name: "",
        last_name: "",
        sex: "male",
        year_group: "5",
        group_id: 5
      }})
    assert redirected_to(conn, 302) =~ "/groups"
  end

  test "show student", %{conn: conn} do
    %User{
      id: 123,
      name: "My Name",
      email: "email@test3.com",
      password_hash: Comeonin.Bcrypt.hashpwsalt("password"),
      admin: true
    } |> Repo.insert

    %Group{
      name: "Test Group 1",
      id: 2
    } |> Repo.insert

    %UserGroup{
      group_id: 2,
      user_id: 123
    } |> Repo.insert

    %Student{
      id: 2,
      first_name: "First",
      last_name: "Last",
      sex: "male",
      year_group: "2",
      group_id: 2
    } |> Repo.insert

    struct(Survey, Map.new(Survey.elems() ++ [:id], fn x ->
      {x, if x == :id || x == :student_id do 2 else Atom.to_string(x) end}
    end)) |> Repo.insert

    conn =
      conn
      |> assign(:current_user, Repo.get(User, 123))

    conn = get conn, student_path(conn, :show, 2)
    assert html_response(conn, 200) =~ "First"
  end

  test "show student unauthorised", %{conn: conn} do
    %User{
      id: 123,
      name: "My Name",
      email: "email@test3.com",
      password_hash: Comeonin.Bcrypt.hashpwsalt("password"),
      admin: true
    } |> Repo.insert

    %Group{
      name: "Test Group 3",
      id: 3
    } |> Repo.insert

    %Group{
      name: "Test Group 4",
      id: 4
    } |> Repo.insert

    %UserGroup{
      group_id: 3,
      user_id: 123
    } |> Repo.insert

    %Student{
      id: 3,
      first_name: "First",
      last_name: "Last",
      sex: "male",
      year_group: "2",
      group_id: 3
    } |> Repo.insert

    %Student{
      id: 4,
      first_name: "First",
      last_name: "Last",
      sex: "male",
      year_group: "2",
      group_id: 4
    } |> Repo.insert

    conn =
      conn
      |> assign(:current_user, Repo.get(User, 123))

    conn = get conn, student_path(conn, :show, 4)
    assert redirected_to(conn, 302) =~ "/groups"
  end

  test "show student non-existent", %{conn: conn} do
    %User{
      id: 1234,
      name: "My Name",
      email: "email@test4.com",
      password_hash: Comeonin.Bcrypt.hashpwsalt("password"),
      admin: true
    } |> Repo.insert

    conn =
      conn
      |> assign(:current_user, Repo.get(User, 1234))

    conn = get conn, student_path(conn, :show, 100)
    assert redirected_to(conn, 302) =~ "/groups"
  end

  describe "downloading a pdf" do
    setup do
      RedisCli.flushdb()
    end

    test "/api/file/:survey_id :: POST", %{conn: conn} do
      with_mock PdfGenerator, [generate_binary!: fn(string, _page_size) -> string end] do
        conn = post conn, student_path(conn, :post_file, "123"),
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
