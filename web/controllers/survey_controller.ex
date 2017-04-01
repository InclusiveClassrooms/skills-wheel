defmodule Skillswheel.SurveyController do
  use Skillswheel.Web, :controller

  alias Skillswheel.{Student, Survey, Group, School}

  defp increment(string) do
    case string do
      "0" -> "1"
      "1" -> "2"
      "2" -> "3"
      "3" -> "4"
      _ -> string
    end
  end

  defp send_to_google_docs(student_id, survey) do
    date = DateTime.utc_now()
    formatted_date = Integer.to_string(date.month)
           <> "/" <> Integer.to_string(date.year)
    student = Repo.get(Student, student_id)
    year = student.year_group
    name = student.first_name <> " " <> student.last_name
    group = Repo.get(Group, student.group_id) |> Repo.preload(:users)
    group_name = group.name
    ta =
      group.users
      |> Enum.map(fn ta -> ta.name end)
      |> Enum.join(", ")

    school = List.first(group.users)
      && List.first(group.users).school_id
      && Repo.get(School, List.first(group.users).school_id).name
      || "Admin School"

    url = "https://script.google.com/macros/s/AKfycbxzdgBRvWFf9CDWjZ4M8VyGlYyMwL3ScEFY9ukqw9xntvV2cQI3/exec?null=null&" <>
    (
      survey
      |> Map.new(fn {k, v} ->
        {k |> String.replace("_", "-") |> String.replace("build", "built"), increment(v)}
      end)
      |> Map.merge(%{"ta" => ta, "student" => name, "school" => school,
        "school-year" => year, "group" => group_name, "date" => formatted_date})
      |> URI.encode_query
    ) <> "&null=null"
    
    HTTPotion.post(url)
  end

  def create_survey(conn, %{"student_id" => student_id, "survey" => survey}, _user) do
    send_to_google_docs(student_id, survey)

    attrs
      =  survey
      |> Map.new(fn {key, val} -> {String.to_atom(key), increment(val)} end)
      |> Map.delete(:student_id)

    student = Repo.get!(Student, student_id)
    changeset = Ecto.build_assoc(student, :surveys) |> Survey.changeset(attrs)

    case Repo.insert(changeset) do
      {:ok, _student} ->
        handle_redirect(conn, :info, "Survey submitted", student_id)
      {:error, _changeset} ->
        handle_redirect(conn, :error, "Error creating survey", student_id)
    end
  end

  defp handle_redirect(conn, flash, message, student_id) do
    conn
    |> put_flash(flash, message)
    |> redirect(to: student_path(conn, :show, student_id))
  end

  def show(conn, %{"id" => student_id}, user) do
    changeset = Survey.changeset(%Survey{})
    latest_survey = Repo.one(from s in Skillswheel.Survey, order_by: [desc: s.inserted_at], limit: 1, where: s.student_id == ^student_id)

    latest_survey =
      case latest_survey do
        nil ->
          nil
        _not_nil ->
          Map.from_struct(latest_survey)
      end

    form = form()

    emotions = [
      "always",
      "sometimes",
      "rarely",
      "never"
    ]

    user = Repo.preload(user, :groups)
    user_groups = Enum.map(user.groups, fn group -> group.id end)

    case Repo.get(Student, student_id) do
      nil ->
        conn
        |> put_flash(:error, "Student does not exist")
        |> redirect(to: group_path(conn, :index))
      student ->
        case Enum.member?(user_groups, student.group_id) do
          true ->
            render conn, "show.html", form: form, changeset: changeset, emotions: emotions, student_id: student_id, latest_survey: latest_survey
          _ ->
            conn
            |> put_flash(:error, "You do not have permission to view this student's profile")
            |> redirect(to: group_path(conn, :index))
        end
    end
  end

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
          [conn, conn.params, conn.assigns.current_user])
  end

  defp form do
    form = [
      %{
        title: "Self Awareness & Self-Esteem",
        questions: [
          %{
            question_title: "Personal Appearance",
            question_subtitle: "Are they able to identify at least three features of their personal appearance e.g. colour hair, colour eyes, height, clothing?",
            question_tag: "personal_appearance"
          },
          %{
            question_title: "Appearance of Others",
            question_subtitle: "Are they able to identify at least three features of others’ personal appearance e.g. colour hair, colour eyes, height, clothing?",
            question_tag: "appearance_others"
          },
          %{
            question_title: "Likes",
            question_subtitle: "Can they identify at least three things that they like?",
            question_tag: "likes"
          },
          %{
            question_title: "Dislikes",
            question_subtitle: "Can they identify at least three things that they dislike?",
            question_tag: "dislikes"
          },
          %{
            question_title: "Strengths",
            question_subtitle: "Can they identify something that they feel they are good at?",
            question_tag: "strengths"
          }
        ],
      },
      %{
        title: "Managing Feelings",
        questions: [
          %{
            question_title: "Identify Emotions in Self",
            question_subtitle: "Are they able to identify how they are feeling in different scenarios?",
            question_tag: "identify_emotions_self"
          },
          %{
            question_title: "Identify Emotions in Others",
            question_subtitle: "Are they able to identify how others might be feelings in different scenarios?",
            question_tag: "identify_emotions_others"
          },
          %{
            question_title: "Bodily Reactions to Emotions",
            question_subtitle: "Can they explain how their body reacts when they feel different emotions e.g. when they are nervous their palms might sweat, they might go red, they might fidget?",
            question_tag: "bodily_reaction_emotions"
          },
          %{
            question_title: "Identifies Appropriate Responses to Emotions",
            question_subtitle: "Are they able to react appropriately to different emotions e.g. can they calm themselves down when they feel angry?",
            question_tag: "identify_response_emotions"
          },
          %{
            question_title: "Follow a Plan to Respond to Emotions",
            question_subtitle: "Can they appropriately follow a plan that they make to deal with a certain emotion e.g. breathe, count to ten and then talk to someone if they feel angry?",
            question_tag: "plan_respond_emotions"
          }
        ],
      },
      %{
        title: "Non-Verbal Communication",
        questions: [
          %{
            question_title: "Good Eye Contact",
            question_subtitle: "Do they follow the good eye contact rule when they talk to others?",
            question_tag: "good_eye_contact"
          },
          %{
            question_title: "Good Distance/Touch",
            question_subtitle: "Do they display appropriate distance and touch when they speak to someone?",
            question_tag: "good_distance_touch"
          },
          %{
            question_title: "Identify Facial Expressions",
            question_subtitle: "Are they able to identify a range of different facial expressions in others?",
            question_tag: "identify_expressions"
          },
          %{
            question_title: "Identifies 'Good Body Language' in Self",
            question_subtitle: "Can they identify when they are displaying good body language e.g. good distance, good touch and good eye contact?",
            question_tag: "body_language_self"
          },
          %{
            question_title: "Identifies 'Good Body Language' in Others",
            question_subtitle: "Can they identify when others are displaying good body language e.g. good distance, good touch and good eye contact?",
            question_tag: "body_language_others"
          }
        ],
      },
      %{
        title: "Verbal Communication",
        questions: [
          %{
            question_title: "Good Volume",
            question_subtitle: "Do they speak with good volume, i.e. not too loudly or quietly?",
            question_tag: "good_volume"
          },
          %{
            question_title: "Good Pace",
            question_subtitle: "Do they speak with good pace, i.e. not too quickly or slowly?",
            question_tag: "good_pace"
          },
          %{
            question_title: "Clarity",
            question_subtitle: "Is their speech clear to others?",
            question_tag: "clear_speech"
          },
          %{
            question_title: "Relevance",
            question_subtitle: "Do they always speak with relevance in a conversation?",
            question_tag: "speak_with_relevance"
          },
          %{
            question_title: "Identifies 'Good Speaking Rules'",
            question_subtitle: "Are they able to identify how good speech sounds e.g. good volume, good pace, good clarity?",
            question_tag: "identify_good_speech"
          }
        ],
      },
      %{
        title: "Planning and Problem Solving",
        questions: [
          %{
            question_title: "Thinks before Reacting",
            question_subtitle: "Do they always think before they react to a problem in school?",
            question_tag: "think_before_react"
          },
          %{
            question_title: "Identifies Problems",
            question_subtitle: "Do they understand when problems have occurred e.g. a fall out on the playground, an unforeseen change to timetabling, difficulties with peers’ friendships.",
            question_tag: "understand_problems_occurred"
          },
          %{
            question_title: "Identifies Examples of 'Good Problem Solving'",
            question_subtitle: "Can they identify situations in which problems were solved appropriately?",
            question_tag: "problems_solved_appropriately"
          },
          %{
            question_title: "Devise a Plan to Solve a Problem",
            question_subtitle: "Can they make a plan to solve a problem that they’re involved in e.g. an approach to dealing with a change in timetabling?",
            question_tag: "make_a_plan"
          },
          %{
            question_title: "Implement a Plan to Solve a Problem",
            question_subtitle: "Can they follow a plan that they have devised to solve a problem that they’re involved in?",
            question_tag: "follow_a_plan"
          }
        ],
      },
      %{
        title: "Relationships, Leaderships and Assertiveness",
        questions: [
          %{
            question_title: "Built and Maintained One Friendship",
            question_subtitle: "Do they have one school-based relationship with a peer that could be termed a friendship?",
            question_tag: "build_one_friendship"
          },
          %{
            question_title: "Built and Maintained Multiple Friendships",
            question_subtitle: "Do they have more than one school-based relationship with a peer that could be termed a friendship?",
            question_tag: "build_multiple_friendships"
          },
          %{
            question_title: "Express Thoughts and Feelings to Others",
            question_subtitle: "Are they able to tell others how they think and feel in an appropriate way in different situations?",
            question_tag: "express_thoughts_to_others"
          },
          %{
            question_title: "Disagree with Others",
            question_subtitle: "Can they appropriately say that they disagree with others’ opinions?",
            question_tag: "disagree_with_others"
          },
          %{
            question_title: "Apologise Appropriately",
            question_subtitle: "Can they say sorry appropriately when it is expected of them?",
            question_tag: "apologise_appropriately"
          }
        ]
      }
    ]

    form
  end
end
