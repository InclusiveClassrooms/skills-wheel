defmodule Skillswheel.User do
  use Skillswheel.Web, :model
  alias Skillswheel.School
  alias Skillswheel.Repo

  schema "users" do
    field :name, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :admin, :boolean
    belongs_to :school, Skillswheel.School

    timestamps()
  end

  def changeset(struct, params \\ :invalid) do
    struct
    |> cast(params, [:email, :name, :password])
    |> validate_format(:email, ~r/@/)
    |> validate_required([:email, :password, :name])
    |> assoc_constraint(:school)
    |> unique_constraint(:email)
  end

  def registration_changeset(struct, params) do
    struct
    |> changeset(params)
    |> email_validation()
    |> cast(params, [:password, :email])
    |> validate_length(:password, min: 6, max: 100)
    |> put_pass_hash()
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end

  defp email_validation(changeset) do
    schools = Repo.all(School)
    school_data = Enum.map(schools, fn school -> {school.email_suffix, school.id} end)
    school_emails = Enum.map(school_data, fn school -> elem(school, 0) end)
    [_prefix, suffix] = get_field(changeset, :email) |> String.split("@")

    if Enum.member?(school_emails, suffix) do
      [{_, school_id}] = Enum.filter(school_data, fn school -> elem(school, 0) == suffix end)
      put_change(changeset, :school_id, school_id)
    else
      add_error(changeset, :email, "Your school is not signed up, contact [this email] to request access")
    end
  end
end
