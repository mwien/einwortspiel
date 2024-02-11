defmodule Einwortspiel.GameServer do
  use GenServer
  alias Einwortspiel.{Game, Notifier}
  
  def child_spec(init_args) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, init_args},
      restart: :transient
    }
  end

  def start_link([game_id, options]) do
    GenServer.start_link(__MODULE__, [game_id, options],
      name: Einwortspiel.Application.via_tuple(game_id)
    )
  end

  def init([game_id, options]) do
    # later add presence back in
    # Phoenix.PubSub.subscribe(Einwortspiel.PubSub, "table_pres:#{table.table_id}")
    {:ok, Game.init(game_id, options)}
  end
 
  def get_game(game_id) do
    case service_name(game_id) do
      nil -> {:error, :invalid_game_id}
      pid -> GenServer.call(pid, {:get_game})
    end
  end

  def join(game_id, player_id, name) do
    case service_name(game_id) do
      nil -> {:error, :invalid_game_id}
      pid -> GenServer.call(pid, {:join, player_id, name})
    end
  end
  
  def start_round(game_id, player_id) do
    case service_name(game_id) do
      nil -> {:error, :invalid_game_id}
      pid -> GenServer.call(pid, {:start_round, player_id})
    end
  end
 
  def submit_clue(game_id, player_id, clue) do
    case service_name(game_id) do
      nil -> {:error, :invalid_game_id}
      pid -> GenServer.call(pid, {:submit_clue, player_id, clue})
    end
  end
  
  def submit_guess(game_id, player_id, guess) do
    case service_name(game_id) do
      nil -> {:error, :invalid_game_id}
      pid -> GenServer.call(pid, {:submit_guess, player_id, guess})
    end
  end

  def handle_call({:get_game}, _from, state) do
    {:reply, {:ok, Game.game_view(state), state}}
  end
  
  def handle_call({:join, player_id, name}, _from, game) do
    case Game.add_player(game, player_id, name) do
      {:ok, {update, new_game}} -> {:reply, :ok, publish_update(new_game, update)}
      {:error, error} -> {:reply, {:error, error}, game}
    end
  end
  
  def handle_call({:start_round, player_id}, _from, game) do
    case Game.start_round(game, player_id) do
      {:ok, {update, new_game}} -> {:reply, :ok, publish_update(new_game, update)}
      {:error, error} -> {:reply, {:error, error}, game}
    end
  end

  def handle_call({:submit_clue, player_id, clue}, _from, game) do
    case Game.submit_clue(game, player_id, clue) do
      {:ok, {update, new_game}} -> {:reply, :ok, publish_update(new_game, update)}
      {:error, error} -> {:reply, {:error, error}, game}
    end
  end

  def handle_call({:submit_guess, player_id, guess}, _from, game) do
    case Game.submit_clue(game, player_id, guess) do
      {:ok, {update, new_game}} -> {:reply, :ok, publish_update(new_game, update)}
      {:error, error} -> {:reply, {:error, error}, game}
    end
  end

  defp publish_update(game, update) do
    Notifier.publish_game_info(game.id, {:update, update})
    game
  end
 
  defp service_name(table_id) do
    GenServer.whereis(Einwortspiel.Application.via_tuple(table_id))
  end
  
  #
  #def submit_clue(game_id, player_id, clue) do
  #  
  #end
  #
  #def submit_guess(game_id, player_id, guess) do
  #  
  #end

  #def handle_info(%{event: "presence_diff", payload: %{joins: joins, leaves: leaves}}, table) do
  #  {
  #    :noreply,
  #    Table.update_connected_players(table, joins, leaves)
  #  }
  #end

  #defp handle_update(table) do
  #  Einwortspiel.Game.Notifier.publish_table(table.table_id, {:update, table})
  #  table
  #end

  # return error (or :ok) to caller
  #defp handle_error(error, player_id) do
  #  Einwortspiel.Game.Notifier.publish_player(player_id, {:error, error})
  #  :ok
  #end
end
