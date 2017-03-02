defmodule Skillswheel.RedisClientSupervisor do
  use Supervisor

  alias Skillswheel.RedisCli

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_) do
    children = [
      worker(RedisCli, ["redis://localhost:6379", :redix], [])
    ]
    supervise(children, strategy: :one_for_one)
  end
end

