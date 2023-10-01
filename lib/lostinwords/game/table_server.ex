defmodule Lostinwords.Game.TableServer do
  use GenServer
  alias Lostinwords.Game.Table

  def child_spec(table) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [table]},
      restart: :transient
    }
  end

  def start_link(table) do
    GenServer.start_link(__MODULE__, table, name: Lostinwords.Application.via_tuple(table.table_id))
  end

  def init(table) do
    Phoenix.PubSub.subscribe(Lostinwords.PubSub, "table_pres:#{table.table_id}")
    {:ok, table}
  end
  
  def handle_call({:join, player_id}, _from, state) do
    case Table.join(state, player_id) do
      # TODO this is ugly
      # execute handle_update independent from return?
      {:ok, table} -> {:reply, table, handle_update(table)
      }
      {:error, :already_joined} -> {:reply, state, state}
    end
  end
  
  def handle_call({:manage_round, command, player_id}, _from, state) do
    case Table.manage_round(state, command) do
      {:ok, table} -> {:reply, :ok, handle_update(table)
      }
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
    {:reply, :ok,
     Table.move(state, player_id, move)
     |> handle_update()}
  end

  # TODO: REMOVE DUPLICATE CODE
  # also in init!
  # check whether there are issues (player being added twice and then not deleted twice)
  def handle_info(%{event: "presence_diff", payload: %{joins: joins, leaves: leaves}}, table) do
    {:noreply, Table.update_active_players(table, joins, leaves)
    #|> handle_update()
    }
    # TODO: client do update themselves?
  end

  defp handle_update(table) do
    Lostinwords.Game.Notifier.publish_table(table.table_id, {:update, table})
    table
  end

  defp handle_error(error, player_id) do
    Lostinwords.Game.Notifier.publish_player(player_id, {:error, error})
  end
end
