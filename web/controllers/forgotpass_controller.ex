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
      |> validate_password(password)
      |> replace_password_in_struct(password)
      |> store_new_user()

    case update do
      {:ok, user} ->
        conn
        |> Auth.login(user)
        |> put_flash(:info, "Password Changed")
        |> redirect(to: user_path(conn, :index))
      {:error, message} ->
        case message do
          "Password Validation Fail" -> display_error(conn, message, &user_path/2)
          _ -> display_error(conn, message, &user_path/2)
        end
      _ -> display_error(conn, "Unknown Error", &user_path/2)
    end
  end

  defp get_email_from_hash(hash) do
    case RedisCli.get(hash) do
      {:ok, nil} -> {:error, "User not in redis"}
      {:ok, email} -> {:ok, email}
      {:error, msg} -> {:error, msg}
    end
  end

  defp get_user_from_email(tuple) do
    case tuple do
      {:ok, email} ->
        case Repo.get_by(User, email: email) do
          user ->
            IEx.pry
            {:ok, user}
          nil -> {:error, "User not in postgres"}
        end
      {:error, error} -> {:error, error}
    end
  end

  defp validate_password(tuple) do
    case tuple do
      {:ok, changeset} -> {:ok, User.put_pass_hash(changeset)}
      {:error, error} -> {:error, error}
    end
  end

  defp replace_password_in_struct(tuple, _password) do
    case tuple do
      {:ok, nil} -> {:error, "NIL VAL"}
      {:ok, user} ->
        pass = "newpass"
        struct(
          user,
          [
            password: pass,
            password_hash: Comeonin.Bcrypt.hashpwsalt(pass)
          ]
        )
        # %User{}
        # |> Changeset.cast(user, [:email])
        # |> Changeset.validate_length(:password, min: 6, max: 100)
      {:error, error} -> {:error, error}
    end
  end

  defp store_new_user(tuple) do
    case tuple do
      {:ok, changeset} -> Repo.insert(changeset)
      {:error, error} -> {:error, error}
    end
  end


  # def update_password(conn, %{"forgotpass" => %{"hash" => hash, "newpass" => %{"password" => password}}}) do
  #   case get_email_from_hash(hash) do
  #     {:ok, } ->

  #     {:error, message} ->
  #       conn
  #       |> put_flash(:error, message)
  #       |> redirect(to: user_path(conn, :new))
  #   end
  #   # case RedisCli.query(["GET", hash]) do
  #   #   {:ok, email} ->
  #   #     case Repo.get_by(User, email: email) do
  #   #       {:ok, user} ->
  #   #         newuser = Ecto.Changeset.change user, password: password
  #   #         case User.registration_changeset(%User{}, newuser) do
  #   #           {:ok, user_with_edited_pass} ->
  #   #             case Repo.update user_with_edited_pass do
  #   #               {:ok, _} ->
  #   #                 conn
  #   #                 |> Auth.login(user)
  #   #                 |> put_flash(:info, "Password Changed")
  #   #                 |> redirect(to: user_path(conn, :index))
  #   #               _ ->
  #   #                 conn
  #   #                 |> put_flash(:info, "Something went wrong")
  #   #                 |> redirect(to: user_path(conn, :new))
  #   #             end
  #   #           _ ->
  #   #             conn
  #   #             |> put_flash(:error, user_path(conn, :new))
  #   #         end
  #   #       _ ->
  #   #         conn
  #   #         |> put_flash(:error, "User is not registered")
  #   #         |> redirect(to: user_path(conn, :new))
  #   #     end
  #   #   {:ok, nil} ->
  #   #     conn
  #   #     |> put_flash(:error, "Your forgotten password token has expired, please try again")
  #   #     |> redirect(to: user_path(conn, :new))
  #   #   _ ->
  #   #     conn
  #   #     |> put_flash(:error, "Database error")
  #   #     |> redirect(to: user_path(conn, :new))
  #   # end
  # end

  # defp get_email_from_hash(hash) do
  #   case RedisCli.query(["GET", hash]) do
  #     {:ok, email} -> {:ok, email}
  #     {:ok, nil} -> {:error, "Your forgotten password token has expired, please try again"}
  #     _ -> {:error, "Database Error"}
  #   end
  # end

  # defp change_password_from_email(email) do
  #   case Repo.get_by(User, email: email) do
  #     {:ok, user} ->
  #       case update_user_pass(user, password) do
  #         {:ok, 
  #       end
  #       # case User.registration_changeset(%User{}, newuser) do
  #       #   {:ok, user_with_edited_pass} ->
  #       #     case Repo.update user_with_edited_pass do
  #       #       {:ok, _} ->
  #       #         conn
  #       #         |> Auth.login(user)
  #       #         |> put_flash(:info, "Password Changed")
  #       #         |> redirect(to: user_path(conn, :index))
  #       #       _ ->
  #       #         conn
  #       #         |> put_flash(:info, "Something went wrong")
  #       #         |> redirect(to: user_path(conn, :new))
  #       #     end
  #       #   _ -> {:error, "Changeset error"}
  #       # end
  #     _ -> {:error, "User is not in database"}
  #   end
  # end

  # defp change_password_from_email(conn, email, password) do
  #   case User |> Repo.get_by(email: email) do
  #     {:ok, user} ->
  #       newuser = Ecto.Changeset.change user, password: password
  #       case User.registration_changeset(%User{}, newuser) do
  #         {:ok, user_with_edited_pass} ->
  #           case Repo.update user_with_edited_pass do
  #             {:ok, _} ->
  #               conn
  #               |> Auth.login(user)
  #               |> put_flash(:info, "Password Changed")
  #               |> redirect(to: user_path(conn, :index))
  #             _ ->
  #               conn
  #               |> put_flash(:info, "Something went wrong")
  #               |> redirect(to: user_path(conn, :new))
  #           end
  #         _ ->
  #           conn
  #           |> put_flash(:error, user_path(conn, :new))
  #       end
  #     _ ->
  #       conn
  #       |> put_flash(:error, "User is not registered")
  #       |> redirect(to: user_path(conn, :new))
  #   end
  # end

    # case get_email_from_hash(hash) |>  do
    #   {:ok, email} ->
    #     change_password_from_email(conn, email, password)
    #   {:error, message} ->
    #     conn
    #     |> put_flash(:error, message)
    #     |> redirect(to: user_path(conn, :new))
    # end

  defp gen_rand_string(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> binary_part(0, length)
  end
end
