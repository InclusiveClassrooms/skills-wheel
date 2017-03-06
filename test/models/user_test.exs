defmodule Skillswheel.UserTest do
   use Skillswheel.ModelCase, async: false

   alias Skillswheel.{User, School}

   setup do
     %School{
       id: 1,
       name: "Test School",
       email_suffix: "test.com"
     } |> Repo.insert
     :ok
   end

   @valid_attrs %{
     email: "email@test.com",
     password: "secretshhh",
     password_hash: Comeonin.Bcrypt.hashpwsalt("secretshhh"),
     admin: true,
     school_id: 1,
     name: "test"
   }
   @invalid_attrs %{email: "test@test.com"}
   @invalid_school %{
     email: "email@testing.com",
     school_id: 2
   }

   test "changeset with valid attributes" do
     changeset = User.changeset(%User{}, @valid_attrs)
     assert changeset.valid?
   end

   test "changeset with invalid attributes" do
     changeset = User.changeset(%User{}, @invalid_attrs)
     refute changeset.valid?
   end

   test "registration_changeset with valid attributes" do
     changeset = User.registration_changeset(%User{}, @valid_attrs)
     assert changeset.valid?
   end

   test "registration_changeset with invalid attributes" do
     changeset = User.registration_changeset(%User{}, @invalid_attrs)
     refute changeset.valid?
   end

   test "registration_changeset with invalid school attributes" do
     changeset = User.registration_changeset(%User{}, @invalid_school)
     refute changeset.valid?
   end

   test "user schema" do
     actual = User.__schema__(:fields)
     expected = [:id, :name, :email, :password_hash, :admin, :school_id, :inserted_at, :updated_at]
     assert actual == expected
   end
end
