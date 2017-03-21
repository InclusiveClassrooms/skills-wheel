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
    many_to_many :groups, Skillswheel.Group, join_through: "users_groups"

    timestamps()
  end

  def validate_password(changeset, params) do
    changeset
    |> cast(params, [:password, :email])
    |> validate_length(:password, min: 6, max: 100)
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
    |> validate_password(params)
    |> put_pass_hash()
  end

  def put_pass_hash(changeset) do
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
    email =
      case get_field(changeset, :email) do
        nil -> "@"
        string ->
          case String.contains? string, "@" do
            true -> string
            false -> "@" 
          end
      end
    [_prefix, suffix] = email |> String.split("@")

    if Enum.member?(school_emails, suffix) do
      [{_, school_id}] = Enum.filter(school_data, fn school -> elem(school, 0) == suffix end)
      put_change(changeset, :school_id, school_id)
    else
      add_error(changeset, :email, "Sorry, it looks like SkillsWheel has not come to your school yet. If you'd like to gain access please get in touch at helen@inclusiveclassrooms.co.uk")
    end
  end
end
