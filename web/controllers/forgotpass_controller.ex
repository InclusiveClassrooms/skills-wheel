defmodule Skillswheel.ForgotpassController do
  use Skillswheel.Web, :controller
  require IEx

  alias Skillswheel.{User, RedisCli, Auth}
  alias Ecto.Changeset

  def index(conn, _params) do
    render conn, "index.html"
  end

  def create(conn, %{"forgotpass" => %{"email" => email}}) do
    rand_string = gen_rand_string(30)

    RedisCli.query(["SET", rand_string, email])

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

  def update_password(conn, %{"forgotpass" => %{"hash" => hash, "newpass" => %{"password" => password}}}) do
    update
      =  get_email_from_hash(hash)
      |> get_user_from_email()
      |> put_new_pass(password)
      # |> validate_password()
      # |> put_pass_hash()
      # |> insert_user()

    # case update do
    #   {:ok, user} ->
    #     conn
    #     |> Auth.login(user)
    #     |> put_flash(:info, "Password Changed")
    #     |> redirect(to: user_path(conn, :index))
    #   {:error, message} ->
    #     case message do
    #       "Password Validation Fail" -> display_error(conn, message, &user_path/2)
    #       _ -> display_error(conn, message, &user_path/2)
    #     end
    #   _ -> display_error(conn, "Unknown Error", &user_path/2)
    # end
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

  def put_new_pass(tuple, password) do
    case tuple do
      {:ok, nil} -> {:error, "NIL"}
      {:ok, struct} -> {:ok, struct}
      {:error, struct} -> {:error, struct}
    end
  end

  # def replace_new_password(tuple, password) do
  #   case tuple do
  #     {:ok, user} ->
  #       params = %{
  #         "username" => user.username,
  #         "email" => user.email,
  #         "password" => password
  #       }
  #       changeset = User.registration_changetset(%User{}, params)
  #       case Repo.(changeset) do
  #         
  #       end
  #     {:error, error} -> {:error, error}
  #   end
  # end

  # def replace_password_in_struct(tuple, password) do
  #   case tuple do
  #     {:ok, user} -> {:ok, %{user | password: password}}
  #     {:error, error} -> {:error, error}
  #   end
  # end

  def validate_password(tuple) do
    case tuple do
      {:ok, user} ->
        params = %{
          "name" => user.name,
          "password" => user.password,
          "email" => user.email
        }
        {:ok, User.validate_password(user, params)}
      {:error, error} -> {:error, error}
    end
  end

  # defp validate_password(tuple) do
  #   case tuple do
  #     {:ok, changeset} -> {:ok, User.put_pass_hash(changeset)}
  #     {:error, error} -> {:error, error}
  #   end
  # end

  # defp replace_password_in_struct(tuple, _password) do
  #   case tuple do
  #     {:ok, nil} -> {:error, "NIL VAL"}
  #     {:ok, user} ->
  #       pass = "newpass"
  #       struct(
  #         user,
  #         [
  #           password: pass,
  #           password_hash: Comeonin.Bcrypt.hashpwsalt(pass)
  #         ]
  #       )
  #       # %User{}
  #       # |> Changeset.cast(user, [:email])
  #       # |> Changeset.validate_length(:password, min: 6, max: 100)
  #     {:error, error} -> {:error, error}
  #   end
  # end

  # defp store_new_user(tuple) do
  #   case tuple do
  #     {:ok, changeset} -> Repo.insert(changeset)
  #     {:error, error} -> {:error, error}
  #   end
  # end

  defp gen_rand_string(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> binary_part(0, length)
  end
end
