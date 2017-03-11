defmodule Skillswheel.Repo.Migrations.AddSurveys do
  use Ecto.Migration

  def change do
    create table(:surveys) do
      add :personal_appearance, :string
      add :appearance_others, :string
      add :likes, :string
      add :dislikes, :string
      add :strengths, :string
      add :identify_emotions_self, :string
      add :identify_emotions_others, :string
      add :bodily_reaction_emotions, :string
      add :identify_response_emotions, :string
      add :plan_respond_emotions, :string
      add :good_eye_contact, :string
      add :good_distance_touch, :string
      add :identify_expressions, :string
      add :body_language_self, :string
      add :body_language_others, :string
      add :good_volume, :string
      add :good_pace, :string
      add :clear_speech, :string
      add :speak_with_relevance, :string
      add :identify_good_speech, :string
      add :think_before_react, :string
      add :understand_problems_occurred, :string
      add :problems_solved_appropriately, :string
      add :make_a_plan, :string
      add :follow_a_plan, :string
      add :build_one_friendship, :string
      add :build_multiple_friendships, :string
      add :express_thoughts_to_others, :string
      add :disagree_with_others, :string
      add :apologise_appropriately, :string
      add :student_id, references(:students)
    end
  end
end

