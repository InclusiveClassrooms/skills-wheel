# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :skillswheel,
  ecto_repos: [Skillswheel.Repo]

# Configures the endpoint
config :skillswheel, Skillswheel.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "RoBmHpD9fll4Z+i9J/yort8U3AEelmCaphcUmQBHlimDvAeGmdzxYuVrL7BbsczP",
  render_errors: [view: Skillswheel.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Skillswheel.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :skillswheel, Skillswheel.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: "  
  email-smtp.us-west-2.amazonaws.com",
  port: 25,
  username: System.get_env("SMTP_USERNAME"),
  password: System.get_env("SMTP_PASSWORD"),
  tls: :always, # can be `:always` or `:never`
  ssl: false, # can be `true`
  retries: 3

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
