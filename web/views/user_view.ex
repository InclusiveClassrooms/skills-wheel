defmodule Skillswheel.UserView do
  @moduledoc false
  use Skillswheel.Web, :view
  alias Skillswheel.User

  def first_name(%User{name: name}) do
    name
    |> String.split(" ")
    |> Enum.at(0)
  end


end
