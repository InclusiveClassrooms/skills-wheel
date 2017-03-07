defmodule Skillswheel.ForgotpassController do
  use Skillswheel.Web, :controller

  alias Skillswheel.{User, RedisCli, Auth}
  alias Ecto.Changeset

  def index(conn, _params) do
    render conn, "index.html"
  end

  def create(conn, %{"forgotpass" => %{"email" => email}}) do
    rand_string = gen_rand_string(30)
    one_day = 24 * 60 * 60

    RedisCli.set(rand_string, email)
    RedisCli.expire(rand_string, one_day)

    email
    |> Skillswheel.Email.forgotten_password_email(rand_string)
    |> Skillswheel.Mailer.deliver_now()

    conn
    |> put_flash(:info, "Email Sent")
    |> redirect(to: forgotpass_path(conn, :index))
  end

  def show(conn, %{"id" => hash}) do
    render conn, "reset.html", hash: hash
  end

  defp display_error(conn, message, path) do
    conn
    |> put_flash(:error, message)
    |> redirect(to: path.(conn, :new))
  end

  def update_password(conn, %{"hash" => hash, "newpass" => %{"password" => password}}) do
    update
      =  get_email_from_hash(hash)
      |> get_user_from_email()
      |> validate_password(password)
      |> put_pass_hash()
      |> update_user()

    case update do
      {:ok, user} ->
        conn
        |> Auth.login(user)
        |> put_flash(:info, "Password Changed")
        |> redirect(to: user_path(conn, :index))
      {:error, message} ->
        case message do
          _ -> display_error(conn, message, &user_path/2)
        end
    end
  end

  def get_email_from_hash(hash) do
    case RedisCli.get(hash) do
      {:ok, nil} -> {:error, "User not in Redis"}
      {:ok, email} -> {:ok, email}
    end
  end

  def get_user_from_email(tuple) do
    case tuple do
      {:ok, email} ->
        case Repo.get_by(User, email: email) do
          nil -> {:error, "User not in Postgres"}
          user -> {:ok, user}
        end
      {:error, error} -> {:error, error}
    end
  end

  def validate_password(tuple, password) do
    case tuple do
      {:ok, user} ->
        params = %{
          "email" => user.email,
          "name" => user.name,
          "password" => password
        }
        changeset = User.validate_password(%User{}, params)
        cond do
          changeset.valid? -> {:ok, changeset}
          true -> {:error, "Invalid password"}
        end
      {:error, struct} -> {:error, struct}
    end
  end

  def put_pass_hash(tuple) do
    case tuple do
      {:ok, changeset} -> {:ok, User.put_pass_hash(changeset)}
      {:error, error} -> {:error, error}
    end
  end

  def update_user(tuple) do
    case tuple do
      {:ok, changeset} ->
        user = Repo.get_by(User, email: changeset.changes.email)
        user = Changeset.change(user, password_hash: changeset.changes.password_hash)
        case Repo.update user do
          {:ok, struct} -> {:ok, struct}
          {:error, error} -> {:error, error}
        end
      {:error, error} -> {:error, error}
    end
  end

  defp gen_rand_string(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> binary_part(0, length)
  end
end
