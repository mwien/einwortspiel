defmodule Einwortspiel.Players do
  alias Einwortspiel.Players.Player

  # TODO
  def init_players() do
    %{}
  end

  def add_player(players, player_id, name) do
    # TODO: check if already exists?
    Map.put(players, player_id, Player.create_player(name)) 
  end

  def update_clue(players, player_id, clue) do 
    Map.update!(players, player_id, &Player.update_clue(&1, clue)) 
  end

  def update_guess(players, player_id, guess) do
    Map.update!(players, player_id, &Player.update_guess(&1, guess)) 
  end

end

