defmodule Skillswheel.GroupView do
  @moduledoc false
  use Skillswheel.Web, :view

  def format_owners(current_user, owners) do
    other_owner_names = Enum.filter(owners, fn owner -> owner.id != current_user.id end)
    case Enum.count other_owner_names do
      0 ->
        "You"
      1 ->
        [%{id: _id, name: name}] = other_owner_names
        "You and #{name}"
      _more ->
        names = Enum.map(other_owner_names, fn owner -> owner.name end)
        joined_names = Enum.join(names, ", ")
        formatted_names = String.replace(joined_names, ~r/,\s([^,]+)$/, " and \\g{1}")
        "You, #{formatted_names}"
    end
  end
end
