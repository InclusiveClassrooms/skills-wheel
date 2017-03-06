alias Skillswheel.{Repo, User}

case Repo.get_by(User, name: "Admin") do
  nil -> 
    Repo.insert! %User{
      name: "Admin",
      email: System.get_env("ADMIN_EMAIL"),
      password: System.get_env("ADMIN_PASSWORD"),
      password_hash: Comeonin.Bcrypt.hashpwsalt(System.get_env("ADMIN_PASSWORD")),
      admin: true
    }
  _user -> IO.puts "Admin already in database"
end

