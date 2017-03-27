ExUnit.start

Ecto.Adapters.SQL.Sandbox.mode(Skillswheel.Repo, :manual)

<%= if ecto do %>
<%= adapter_config[:test_setup_all] %>
<% end %>

