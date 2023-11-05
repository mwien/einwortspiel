defmodule Lostinwords.Game.Player do
  alias __MODULE__
  alias Lostinwords.Generator

  # is spectator first after joining round!
  # handle this somehow!
  defstruct [
    :active,
    :animal,
    :id,
    :name, 
    :score,
    :spectator
  ]

  def create_player(id) do
    {name, animal} = Generator.gen_animal()
    %Player{
      active: true, # should be fine?
      animal: animal,
      id: id,
      name: name,
      score: 0,
      spectator: true
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
