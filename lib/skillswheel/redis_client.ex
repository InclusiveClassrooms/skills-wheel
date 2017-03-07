defmodule Skillswheel.RedisCli do
  def start_link(connection, name) do
    Redix.start_link(connection, name: name)
  end

  def query(param), do: Redix.command(:redix, param)

  def get(key), do: query(["get", key])
  def set(key, value), do: query(["set", key, value])
  def expire(key, seconds), do: query(["expire", key, seconds])
  def flushdb do
    query(["flushdb"])
    :ok
  end
end

