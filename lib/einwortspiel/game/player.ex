defmodule Einwortspiel.Game.Player do
  alias __MODULE__
  alias Einwortspiel.Generator

  # is spectator first after joining round!
  # handle this somehow!
  defstruct [
    :active,
    :id,
    :name, 
    :score,
    :spectator
  ]

  def create_player(id) do
    %Player{
      active: true, # should be fine?
      id: id,
      name: Generator.gen_name(),
      score: 0,
      spectator: false # TODO: spectator handling
    }
  end

  def update_player(player, attribute, value) do
    Map.put(player, attribute, value) 
  end

  def update_score(player, plus_score) do
    Map.put(player, :score, player.score + plus_score)
  end

  def update_active(player, set_to, update_list) do
    cond do
      Enum.member?(update_list, player.id) -> Map.put(player, :active, set_to)
      true -> player
    end
  end
  
end
