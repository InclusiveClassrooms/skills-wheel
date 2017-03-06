# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Skillswheel.Repo.insert!(%Skillswheel.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Skillswheel.Repo
alias Skillswheel.User

case Repo.get_by(User, name: "Admin") do
  {:ok, _user} -> IO.puts "Admin already in database"
  _ -> 
    Repo.insert! %User{
      name: "Admin",
      email: System.get_env("ADMIN_EMAIL"),
      password: System.get_env("ADMIN_PASSWORD"),
      password_hash: Comeonin.Bcrypt.hashpwsalt(System.get_env("ADMIN_PASSWORD")),
      admin: true
    }
end

