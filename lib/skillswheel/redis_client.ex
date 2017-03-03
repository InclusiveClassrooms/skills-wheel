defmodule Skillswheel.RedisCli do
  def start_link(connection, name) do
    Redix.start_link(connection, name: name)
  end

  def query(param) do
    Redix.command(:redix, param)
  end
end

