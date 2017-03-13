defmodule Skillswheel.Survey do
  use Skillswheel.Web, :model

  alias Skillswheel.Student

  schema "surveys" do
    # SELF AWARENESS & SELF-ESTEEM
    field :personal_appearance, :string
    field :appearance_others, :string
    field :likes, :string
    field :dislikes, :string
    field :strengths, :string
    # MANAGING FEELINGS
    field :identify_emotions_self, :string
    field :identify_emotions_others, :string
    field :bodily_reaction_emotions, :string
    field :identify_response_emotions, :string
    field :plan_respond_emotions, :string
    # NON-VERBAL COMMUNICATION
    field :good_eye_contact, :string
    field :good_distance_touch, :string
    field :identify_expressions, :string
    field :body_language_self, :string
    field :body_language_others, :string
    # VERBAL COMMUNICATION
    field :good_volume, :string
    field :good_pace, :string
    field :clear_speech, :string
    field :speak_with_relevance, :string
    field :identify_good_speech, :string
    # PLANNING AND PROBLEM SOLVING
    field :think_before_react, :string
    field :understand_problems_occurred, :string
    field :problems_solved_appropriately, :string
    field :make_a_plan, :string
    field :follow_a_plan, :string
    # RELATIONSHIPS, LEADERSHIPS AND ASSERTIVENESS
    field :build_one_friendship, :string
    field :build_multiple_friendships, :string
    field :express_thoughts_to_others, :string
    field :disagree_with_others, :string
    field :apologise_appropriately, :string
    belongs_to :student, Student

    timestamps()
  end

  def changeset(struct, params \\ :invalid) do
    struct
    |> cast(params, elems())
    |> validate_required(elems())
    |> assoc_constraint(:student)
  end

  def elems() do
    [:personal_appearance,
     :appearance_others,
     :likes,
     :dislikes,
     :strengths,
     :identify_emotions_self,
     :identify_emotions_others,
     :bodily_reaction_emotions,
     :identify_response_emotions,
     :plan_respond_emotions,
     :good_eye_contact,
     :good_distance_touch,
     :identify_expressions,
     :body_language_self,
     :body_language_others,
     :good_volume,
     :good_pace,
     :clear_speech,
     :speak_with_relevance,
     :identify_good_speech,
     :think_before_react,
     :understand_problems_occurred,
     :problems_solved_appropriately,
     :make_a_plan,
     :follow_a_plan,
     :build_one_friendship,
     :build_multiple_friendships,
     :express_thoughts_to_others,
     :disagree_with_others,
     :apologise_appropriately,
     :student_id]
  end
end
