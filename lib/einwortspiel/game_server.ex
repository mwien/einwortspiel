defmodule Einwortspiel.GameServer do
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
  
  def get_game(game_id) do
    
  end

  # TODO: pass player_id? -> yes can only add player for yourself?!
  def add_player(game_id, player_id, player) do
    
  end

  # player_id? 
  def start_round(game_id) do
    
  end

  def submit_clue(game_id, player_id, clue) do
    
  end

  def submit_guess(game_id, player_id, guess) do
    
  end

  def handle_call({:submit_clue, player_id, clue}, _from, {game_state, players} = state) do
    case GameState.check(game_state, :submit_clue) do
      {:ok, game_state} -> {:reply, :ok, 
          {game_state, Players.update_clue(players, player_id, clue)} # TODO: handle update
        }
      {:error, error} -> {:reply, {:error, error}, state}
    end 
  end

  def handle_call({:submit_guess, player_id, guess}, _from, {game_state, players} = state) do
    case GameState.check(game_state, :submit_guess) do
      {:ok, game_state} -> {:reply, :ok, 
          {game_state, Players.update_guess(players, player_id, guess)} # TODO: handle update
        }
      {:error, error} -> {:reply, {:error, error}, state}
    end
  end

  def handle_call({:get_table}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:create_player, player_id}, _from, state) do
    case Table.create_player(state, player_id) do
      {:ok, table} -> {:reply, :ok, handle_update(table)}
      {:error, error} -> {:reply, handle_error(error, player_id), state}
    end
  end

  def handle_call({:update_player, player_id, attribute, value}, _from, state) do
    case Table.update_player(state, player_id, attribute, value) do
      {:ok, table} -> {:reply, :ok, handle_update(table)}
      {:error, error} -> {:reply, handle_error(error, player_id), state}
    end
  end

  def handle_call({:manage_game, command, player_id}, _from, state) do
    case Table.manage_game(state, command) do
      {:ok, table} -> {:reply, :ok, handle_update(table)}
      {:error, error} -> {:reply, handle_error(error, player_id), state}
    end
  end

  def handle_call({:make_move, player_id, move}, _from, state) do
    case Table.make_move(state, player_id, move) do
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
