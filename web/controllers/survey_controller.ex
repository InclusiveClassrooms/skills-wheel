defmodule Skillswheel.SurveyController do
  use Skillswheel.Web, :controller

  alias Skillswheel.{Student, Survey}

  def create(conn, %{"survey" => survey}, _user) do
    student_id = survey["student_id"]
    attrs
      =  survey
      |> Map.new(fn {key, val} -> {String.to_atom(key), val} end)
      |> Map.delete(:student_id)
    student = Repo.get!(Student, student_id)
    changeset = Ecto.build_assoc(student, :surveys) |> Student.changeset(attrs)

    case Repo.insert(changeset) do
      {:ok, _student} ->
        handle_redirect(conn, :info, "Survey created!", student_id)
      {:error, _changeset} ->
        handle_redirect(conn, :error, "Error creating survey", student_id)
    end
  end

  defp handle_redirect(conn, flash, message, student_id) do
    conn
    |> put_flash(flash, message)
    |> redirect(to: student_path(conn, :show, student_id))
  end

  def show(conn, %{"id" => _student_id}, user) do
    changeset = Survey.changeset(%Survey{})
    form = [
      %{ 
        title: "Self Awareness & Self-Esteem",
        questions: [
          %{
            question_title: "Personal Appearance",
            question_subtitle: "Are they able to identify at least three features of their personal appearance e.g. colour hair, colour eyes, height, clothing?"
          },
          %{
            question_title: "Appearance of Others",
            question_subtitle: "Are they able to identify at least three features of others’ personal appearance e.g. colour hair, colour eyes, height, clothing?"
          },
          %{
            question_title: "Likes",
            question_subtitle: "Can they identify at least three things that they like?"
          },
          %{
            question_title: "Dislikes",
            question_subtitle: "Can they identify at least three things that they dislike?"
          },
          %{
            question_title: "Strengths",
            question_subtitle: "Can they identify something that they feel they are good at?"
          }
        ],
      },
      %{
        title: "Managing Feelings",
        questions: [
          %{
            question_title: "Identify Emotions in Self",
            question_subtitle: "Are they able to identify how they are feeling in different scenarios?"
          },
          %{
            question_title: "Identify Emotions in Others",
            question_subtitle: "Are they able to identify how others might be feelings in different scenarios?"
          },
          %{
            question_title: "Bodily Reactions to Emotions",
            question_subtitle: "Can they explain how their body reacts when they feel different emotions e.g. when they are nervous their palms might sweat, they might go red, they might fidget?"
          },
          %{
            question_title: "Identifies Appropriate Responses to Emotions",
            question_subtitle: "Are they able to react appropriately to different emotions e.g. can they calm themselves down when they feel angry?"
          },
          %{
            question_title: "Follow a Plan to Respond to Emotions",
            question_subtitle: "Can they appropriately follow a plan that they make to deal with a certain emotion e.g. breathe, count to ten and then talk to someone if they feel angry?
          "}
        ],
      },
      %{
        title: "Non-Verbal Communication",
        questions: [
          %{
            question_title: "Good Eye Contact",
            question_subtitle: "Do they follow the good eye contact rule when they talk to others?"
          },
          %{
            question_title: "Good Distance/Touch",
            question_subtitle: "Do they display appropriate distance and touch when they speak to someone?"
          },
          %{
            question_title: "Identify Facial Expressions",
            question_subtitle: "Are they able to identify a range of different facial expressions in others?"
          },
          %{
            question_title: "Identifies 'Good Body Language' in Self",
            question_subtitle: "Can they identify when they are displaying good body language e.g. good distance, good touch and good eye contact?"
          },
          %{
            question_title: "Identifies 'Good Body Language' in Others",
            question_subtitle: "Can they identify when others are displaying good body language e.g. good distance, good touch and good eye contact?"
          }
        ],
      },
      %{
        title: "Verbal Communication",
        questions: [
          %{
            question_title: "Good Volume",
            question_subtitle: "Do they speak with good volume, i.e. not too loudly or quietly?"
          },
          %{
            question_title: "Good Pace",
            question_subtitle: "Do they speak with good pace, i.e. not too quickly or slowly?"
          },
          %{
            question_title: "Clarity",
            question_subtitle: "Is their speech clear to others?"
          },
          %{
            question_title: "Relevance",
            question_subtitle: "Do they always speak with relevance in a conversation?"
          },
          %{
            question_title: "Identifies 'Good Speaking Rules'",
            question_subtitle: "Are they able to identify how good speech sounds e.g. good volume, good pace, good clarity?
          "}
        ],
      },
      %{
        title: "Planning and Problem Solving",
        questions: [
          %{
            question_title: "Thinks before Reacting",
            question_subtitle: "Do they always think before they react to a problem in school?"
          },
          %{
            question_title: "Identifies Problems",
            question_subtitle: "Do they understand when problems have occurred e.g. a fall out on the playground, an unforeseen change to timetabling, difficulties with peers’ friendships."
          },
          %{
            question_title: "Identifies Examples of 'Good Problem Solving'",
            question_subtitle: "Can they identify situations in which problems were solved appropriately?"
          },
          %{
            question_title: "Devise a Plan to Solve a Problem",
            question_subtitle: "Can they make a plan to solve a problem that they’re involved in e.g. an approach to dealing with a change in timetabling?"
          },
          %{
            question_title: "Implement a Plan to Solve a Problem",
            question_subtitle: "Can they follow a plan that they have devised to solve a problem that they’re involved in?
          "}
        ],
      },
      %{
        title: "Relationships, Leaderships and Assertiveness",
        questions: [
          %{
            question_title: "Built and Maintained One Friendship",
            question_subtitle: "Do they have one school-based relationship with a peer that could be termed a friendship?"
          },
          %{
            question_title: "Built and Maintained Multiple Friendships",
            question_subtitle: "Do they have more than one school-based relationship with a peer that could be termed a friendship?"
          },
          %{
            question_title: "Express Thoughts and Feelings to Others",
            question_subtitle: "Are they able to tell others how they think and feel in an appropriate way in different situations?"
          },
          %{
            question_title: "Disagree with Others",
            question_subtitle: "Can they appropriately say that they disagree with others’ opinions?"
          },
          %{
            question_title: "Apologise Appropriately",
            question_subtitle: "Can they say sorry appropriately when it is expected of them?
          "}
        ]
      }
    ]

    render conn, "show.html", form: form, changeset: changeset
  end

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
          [conn, conn.params, conn.assigns.current_user])
  end
end
