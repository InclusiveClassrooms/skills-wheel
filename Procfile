web: MIX_ENV=prod
mix ecto.migrate
&& mix run priv/repo/seeds.exs
&& mix phoenix.server
