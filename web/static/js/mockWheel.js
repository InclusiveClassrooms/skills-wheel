export var MockWheel = {
  run: function () {
    arr = [
      {question:"ta",answer:"YourName"},
      {question:"student",answer:"ChildName"},
      {question:"school",answer:"SchoolName"},
      {question:"school-yearr",answer:"Year"},
      {question:"group",answer:"GroupName"},
      {question:"date",answer:"MM/YY"},
      {question:"personal-appearance",answer:"3"},
      {question:"appearance_others",answer:"1"},
      {question:"likes",answer:"1"},
      {question:"dislikes",answer:"1"},
      {question:"strengths",answer:"1"},
      {question:"identify_emotions_self",answer:"1"},
      {question:"identify_emotions_others",answer:"1"},
      {question:"bodily_reaction_emotions",answer:"1"},
      {question:"identify_response_emotions",answer:"2"},
      {question:"plan_respond_emotions",answer:"1"},
      {question:"good_eye_contact",answer:"1"},
      {question:"good_distance_touch",answer:"1"},
      {question:"identify_expressions",answer:"2"},
      {question:"body_language_self",answer:"3"},
      {question:"body_language_others",answer:"1"},
      {question:"good_volume",answer:"1"},
      {question:"good_pace",answer:"1"},
      {question:"clear_speech",answer:"1"},
      {question:"speak_with_relevance",answer:"1"},
      {question:"identify_good_speech",answer:"1"},
      {question:"think_before_react",answer:"1"},
      {question:"understand_problems_occurred",answer:"1"},
      {question:"problems_solved_appropriately",answer:"3"},
      {question:"make_a_plan",answer:"1"},
      {question:"follow_a_plan",answer:"1"},
      {question:"built_one_friendship",answer:"1"},
      {question:"built_multiple_friendships",answer:"2"},
      {question:"express_thoughts_to_others",answer:"1"},
      {question:"disagree_with_others",answer:"2"},
      {question:"apologise_appropriately",answer:"1"}
    ]

    Wheel.draw(
      arr,
      '#wheel-container',
      {centre: 250, height: 500, width: 500},
      '../images/'
    )
  }
}
