defmodule Skillswheel.SurveyViewTest do
  use Skillswheel.ConnCase, async: true
  alias Skillswheel.SurveyView

  test "get_int_string" do
    tuple = {"", 1}
    actual = SurveyView.get_int_string(tuple)
    expected = "2"

    assert actual == expected
  end

  test "atom_title" do
    section = {%{title: "title with more than one word", subtitle: "subtitle"}, "more"}
    actual = SurveyView.atom_title(section)
    expected = :"title-with-more-than-one-word"

    assert actual == expected
  end
end
