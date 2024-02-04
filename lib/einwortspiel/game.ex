defmodule Einwortspiel.Game do
  alias Einwortspiel.Game.{Table, Supervisor}
  
  # TODO: always check that table_id exists as service name and handle error?

  # TODO: specify the content of get_game(game_id) which initially fetches game info 
  # TODO: specify the continuous updates to this data structure via pubsup
  # TODO: implement functions in table.ex which for these tasks -> start with first one and naive updates (full resend) and do second one later


  # TODO: maybe specify game struct, which is transparent??? -> sounds like a decent idea?!

  defstruct [
    :words,
    :players,
    :clues,
    :guesses,
    :state
  ]


  # new game API 
  def open_game(options) do
    
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
  

  # old game API
  def create_table(options) do
    Supervisor.create_table(options)
  end

  def get_table(table_id) do
    case service_name(table_id) do
      nil -> {:error, :redirect}
      pid -> GenServer.call(pid, {:get_table})
    end
  end

  def create_player(table_id, player_id) do
    service_name(table_id)
    |> GenServer.call({:create_player, player_id})
  end

  # possible attributes: 
  # :name -> name of player
  def update_player(table_id, player_id, attribute, value) do
    service_name(table_id)
    |> GenServer.call({:update_player, player_id, attribute, value})
  end
  
  # rename to has_player?
  def has_player?(table, player_id) do
    Map.has_key?(table.players, player_id)
  end

  # possible commands: 
  # :start -> for starting the (next) round
  def manage_game(table_id, command, player_id) do
    service_name(table_id)
    |> GenServer.call({:manage_game, command, player_id})
  end

  # check whether new round can be started
  def ready_to_start?(table) do
    Table.ready_to_start?(table)
  end


  # possible moves: 
  # {:submit_clue, clue} 
  # {:submit_guess, guess}
  def make_move(table_id, player_id, move) do
    service_name(table_id)
    |> GenServer.call({:make_move, player_id, move})
  end
 
  defp service_name(table_id) do
    GenServer.whereis(Einwortspiel.Application.via_tuple(table_id))
  end
end
