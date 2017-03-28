defmodule Skillswheel.ForgotpassController do
  @moduledoc """
  # Forgotten Password

  ### Views:
  * index
  Where a user can send an email to their email address
  This will send a link for them to reset their password with
  * show
  Where a user can reset their password
  ### Endpoints
  * create
  The endpoint for recieving the form from `index`
  - Generates a random hash
  - Stores this temporary hash in redis
  - Sends a link to the user corresponding to this hash
  * update_password
  The endpoint for recievign the form from `show`
  - Validates incoming hash
  - Fetches user from postgres
  - Validates password
  - Replaces old password with new one
  """

  use Skillswheel.Web, :controller

  alias Skillswheel.{User, RedisCli, Auth, Email, Mailer}
  alias Ecto.Changeset

  def index(conn, _params) do
    render conn, "index.html"
  end

  def create(conn, %{"forgotpass" => %{"email" => email}}) do
    rand_string = gen_rand_string(30)
    one_day = 24 * 60 * 60

    redis_task = Task.async(fn ->
      RedisCli.set(rand_string, email)
      RedisCli.expire(rand_string, one_day)
    end)

    email_task = Task.async(fn ->
      email
      |> Email.forgotten_password_email(rand_string)
      |> Mailer.deliver_now()
    end)

    Task.await(redis_task)
    Task.await(email_task)

    conn
    |> put_flash(:info, "Email Sent")
    |> redirect(to: forgotpass_path(conn, :index))
  end

  def show(conn, %{"id" => hash}) do
    render conn, "reset.html", hash: hash
  end

  defp display_error(conn, message, path, hash) do
    conn
    |> put_flash(:error, message)
    |> redirect(to: path.(conn, :show, hash))
  end

  defp display_error(conn, message, path) do
    conn
    |> put_flash(:error, message)
    |> redirect(to: path.(conn, :new))
  end

  defp error_handle(tuple, func, arg \\ nil) do
    case tuple do
      {:ok, data} ->
        if arg do
          func.(data, arg)
        else
          func.(data)
        end
      {:error, error} -> {:error, error}
    end
  end

  def update_password(conn, %{"hash" => hash, "newpass" => %{"password" => password}}) do
    update
      =  {:ok, hash}
      |> error_handle(&get_email_from_hash/1)
      |> error_handle(&get_user_from_email/1)
      |> error_handle(&validate_password/2, password)
      |> error_handle(&put_pass_hash/1)
      |> error_handle(&update_user/1)

    case update do
      {:ok, user} ->
        conn
        |> Auth.login(user)
        |> put_flash(:info, "Password Changed")
        |> redirect(to: group_path(conn, :index))
      {:error, message} ->
        case message do
          "invalid_pass" ->
            message = "Invalid, ensure your password is 6-20 characters"
            display_error(conn, message, &forgotpass_path/3, hash)
          _ -> display_error(conn, message, &user_path/2)
        end
    end
  end

  def get_email_from_hash(hash) do
    case RedisCli.get(hash) do
      {:ok, nil} -> {:error, "The email link has expired"}
      {:ok, email} -> {:ok, email}
    end
  end

  def get_user_from_email(email) do
    case Repo.get_by(User, email: email) do
      nil -> {:error, "User has not been registered"}
      user -> {:ok, user}
    end
  end

  def validate_password(user, password) do
    params = %{
      "email" => user.email,
      "name" => user.name,
      "password" => password
    }
    changeset = User.validate_password(%User{}, params)

    case changeset.valid? do
      true -> {:ok, changeset}
      false -> {:error, "invalid_pass"}
    end
  end

  def put_pass_hash(changeset), do: {:ok, User.put_pass_hash(changeset)}

  def update_user(changeset) do
    User
    |> Repo.get_by(email: changeset.changes.email)
    |> Changeset.change(password_hash: changeset.changes.password_hash)
    |> Repo.update()
  end

  defp gen_rand_string(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> binary_part(0, length)
  end
end
