defmodule Einwortspiel.Game.TableSupervisor do
  use DynamicSupervisor

  alias Einwortspiel.Game.Table

  def start_link(_opts) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def open_table(options) do
    table = Table.open_table(options)
    DynamicSupervisor.start_child(__MODULE__, {Einwortspiel.Game.TableServer, table})
    table.table_id
  end

  def abandon_table(_table_id) do
    # TODO
  end
end
