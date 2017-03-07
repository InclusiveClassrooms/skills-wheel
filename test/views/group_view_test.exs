defmodule Skillswheel.GroupViewTest do
  use Skillswheel.ConnCase, async: true
  alias Skillswheel.GroupView

  test "format_owners 1 owner" do
    current_user = %{
      id: 100,
      name: "Group Owner"
    }
    owners = [
      %{
        id: 100,
        name: "Group Owner"
      }
    ]
    _group_owners = GroupView.format_owners(current_user, owners)
    assert _group_owners = "You"
  end

  test "format_owners 2 owners" do
    current_user = %{
      id: 100,
      name: "Group Owner"
    }
    owners = [
      %{
        id: 100,
        name: "Group Owner"
      },
      %{
        id: 200,
        name: "Group Owner 2"
      }
    ]
    _group_owners = GroupView.format_owners(current_user, owners)
    assert _group_owners = "You and Group Owner 2"
  end

  test "format_owners more than 2 owners" do
    current_user = %{
      id: 100,
      name: "Group Owner"
    }
    owners = [
      %{
        id: 100,
        name: "Group Owner"
      },
      %{
        id: 200,
        name: "Group Owner 2"
      },
      %{
        id: 300,
        name: "Group Owner 3"
      },
      %{
        id: 400,
        name: "Group Owner 4"
      }
    ]
    _multiple_group_owners = GroupView.format_owners(current_user, owners)
    assert _multiple_group_owners = "You, Group Owner 2, Group Owner 3 and Group Owner 4"
  end
end
