defmodule Skillswheel.Email do
  use Bamboo.Phoenix, view: Skillswheel.EmailView

  def forgotten_password_email(email_address, rand_string) do
    new_email()
      |> to(email_address)
      |> from("inclusiveclassroomstest@gmail.com")
      |> subject("Welcome!")
      |> text_body("Please visit https://skillswheel.herokuapp.com/forgotpass/" <> rand_string)
  end
end
