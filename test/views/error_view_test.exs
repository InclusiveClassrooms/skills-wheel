defmodule Skillswheel.ErrorViewTest do
  use Skillswheel.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View
  import Skillswheel.ErrorHelpers

  test "renders 404.html" do
    assert render_to_string(Skillswheel.ErrorView, "404.html", []) ==
           "Page not found"
  end

  test "render 500.html" do
    assert render_to_string(Skillswheel.ErrorView, "500.html", []) ==
           "Internal server error"
  end

  test "render any other" do
    assert render_to_string(Skillswheel.ErrorView, "505.html", []) ==
           "Internal server error"
  end

  test "translate_error function, empty opts" do
    assert translate_error({"error", %{}}) == "error"
  end

  test "translate_error function opts with count" do
    assert translate_error({"error", %{count: 1}}) == "error"
  end
end
