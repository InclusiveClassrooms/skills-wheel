defmodule Skillswheel.UserViewTest do
  use Skillswheel.ConnCase, async: true
  alias Skillswheel.User

  test "first_name" do
    first_name = Skillswheel.UserView.first_name(%User{name: "First Last"})
    assert first_name, "First"
  end
  
end
