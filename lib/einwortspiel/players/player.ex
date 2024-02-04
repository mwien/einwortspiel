defmodule Einwortspiel.Game.Player do
  alias __MODULE__

  defstruct [
    :connected,
    :name,
    :role,
    :score
  ]
  
  def create_player(name) do
    %Player{
      # should be fine?
      connected: true,
      name: name,
      role: :active, # other option passive
      score: 0
    }
  end

  def update_player(player, attribute, value) do
    Map.put(player, attribute, value)
  end

  def update_score(player, plus_score) do
    Map.put(player, :score, player.score + plus_score)
  end

  # rewrite
  #def update_connected(player, set_to, update_list) do
    #cond do
    #  Enum.member?(update_list, player.id) -> Map.put(player, :connected, set_to)
    #  true -> player
    #end
  #end
end
