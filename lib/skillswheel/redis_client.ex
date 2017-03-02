defmodule Skillswheel.RedisCli do
  def start_link(connection, name) do
    Redix.start_link(connection, name: name)
  end

  def query(param) do
    case Redix.command(:redix, param) do
      {:ok, result} -> result
      {:error, error} -> error
      _ -> nil
    end
  end
end

