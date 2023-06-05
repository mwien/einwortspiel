defmodule Lostinwords.Game.TableSupervisor do
  use DynamicSupervisor

  alias Lostinwords.Game.Table

  def start_link(_opts) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def open_table() do
    table = Table.open_table()
    DynamicSupervisor.start_child(__MODULE__, {Lostinwords.Game.TableServer, table})
    table.table_id
  end

  def abandon_table(_table_id) do
    # TODO
  end
end
