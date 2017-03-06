defmodule Skillswheel.RedisCli do
  def start_link(connection, name) do
    Redix.start_link(connection, name: name)
  end

  def query(param), do: Redix.command(:redix, param)

  def get(param), do: query(["get", param])
  def set(param1, param2), do: query(["set", param1, param2])
  def flushdb do
    query(["flushdb"])
    :ok
  end
end

