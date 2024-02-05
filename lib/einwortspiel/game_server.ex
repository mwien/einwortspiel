defmodule Einwortspiel.GameServer do
  use GenServer
  alias Einwortspiel.Game
  
  def child_spec(game) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [game]},
      restart: :transient
    }
  end

  def start_link(game) do
    GenServer.start_link(__MODULE__, game,
      name: Einwortspiel.Application.via_tuple(Game.get_game_id(game))
    )
  end

  def init(game) do
    # later add presence back in
    # Phoenix.PubSub.subscribe(Einwortspiel.PubSub, "table_pres:#{table.table_id}")
    {:ok, game}
  end
  
  def get_game(game_id) do
    service_name(game_id)
    |> GenServer.call({:get_game})
  end
  
  def handle_call({:get_game}, _from, state) do
    {:reply, state, state}
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
