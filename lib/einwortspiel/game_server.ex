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
    service_name(game_id)
    |> GenServer.call({:get_game})
  end

  def join(game_id, player_id, name) do
    service_name(game_id)
    |> GenServer.call({:join, player_id, name})
  end
 
  # TODO: add error handling (game does not exist)
  def handle_call({:get_game}, _from, state) do
    {:reply, {:ok, Game.get_gameview(state), state}}
  end
  
  def handle_call({:join, player_id, name}, _from, game) do
    case Game.add_player(game, player_id, name) do
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
  
  #def add_player(game_id, player_id, player) do
  #  
  #end
  #
  # player_id? 
  #def start_round(game_id) do
  #  
  #end
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
