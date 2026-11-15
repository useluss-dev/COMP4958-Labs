defmodule Card.Application do
  @registry Card.Registry
  @table Card.Table

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, [name: @registry, keys: :unique]},
      {PartitionSupervisor,
       name: Card.DynamicSupervisors, child_spec: Card.DynamicSupervisor, partitions: 4}
    ]

    :ets.new(@table, [:named_table, :public])
    opts = [strategy: :one_for_one, name: Card.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
