defmodule Einwortspiel.Game.TableServer do
  use GenServer
  alias Einwortspiel.Game.Table

  def child_spec(table) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [table]},
      restart: :transient
    }
  end

  def start_link(table) do
    GenServer.start_link(__MODULE__, table,
      name: Einwortspiel.Application.via_tuple(table.table_id)
    )
  end

  def init(table) do
    Phoenix.PubSub.subscribe(Einwortspiel.PubSub, "table_pres:#{table.table_id}")
    {:ok, table}
  end

  def handle_call({:get_table}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:join, player_id}, _from, state) do
    case Table.join(state, player_id) do
      {:ok, table} -> {:reply, :ok, handle_update(table)}
      {:error, error} -> {:reply, handle_error(error, player_id), state}
    end
  end

  def handle_call({:manage_round, command, player_id}, _from, state) do
    case Table.manage_round(state, command) |> IO.inspect() do
      {:ok, table} -> {:reply, :ok, handle_update(table)}
      {:error, error} -> {:reply, handle_error(error, player_id), state}
    end
  end

  def handle_call({:set_attribute, player_id, attribute, value}, _from, state) do
    case Table.set_attribute(state, player_id, attribute, value) do
      {:ok, table} -> {:reply, :ok, handle_update(table)}
      {:error, error} -> {:reply, handle_error(error, player_id), state}
    end
  end

  def handle_call({:move, player_id, move}, _from, state) do
    case Table.move(state, player_id, move) do
      {:ok, table} -> {:reply, :ok, handle_update(table)}
      {:error, error} -> {:reply, handle_error(error, player_id), state}
    end
  end

  def handle_info(%{event: "presence_diff", payload: %{joins: joins, leaves: leaves}}, table) do
    {
      :noreply,
      Table.update_connected_players(table, joins, leaves)
    }
  end

  defp handle_update(table) do
    Einwortspiel.Game.Notifier.publish_table(table.table_id, {:update, table})
    table
  end

  defp handle_error(error, player_id) do
    Einwortspiel.Game.Notifier.publish_player(player_id, {:error, error})
    :ok
  end
end
