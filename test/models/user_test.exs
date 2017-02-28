defmodule Skillswheel.UserTest do
   use Skillswheel.ModelCase

   alias Skillswheel.User

   @valid_attrs %{
     email: "email@email.com",
     password: "secretshhh",
     admin: true,
     school_id: 1,
     name: "test"
   }
   @invalid_attrs %{}

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
end
