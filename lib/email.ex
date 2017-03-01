defmodule Skillswheel.Email do
  use Bamboo.Phoenix, view: Skillswheel.EmailView

  def forgotten_password_email(email_address) do
    new_email()
      |> to(email_address)
      |> from("shouston3@me.com")
      |> subject("Welcome!")
      |> text_body("Welcome")
  end
end
