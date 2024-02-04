defmodule Einwortspiel.Game.Player do
  alias __MODULE__
  alias Einwortspiel.Generator

  defstruct [
    :active,
    :connected,
    :id,
    :name,
    :score
  ]

  def create_player(id) do
    %Player{
      active: true,
      # should be fine?
      connected: true,
      id: id,
      name: Generator.gen_name(),
      score: 0
    }
  end

  def update_player(player, attribute, value) do
    Map.put(player, attribute, value)
  end

  def update_score(player, plus_score) do
    Map.put(player, :score, player.score + plus_score)
  end

  def update_connected(player, set_to, update_list) do
    cond do
      Enum.member?(update_list, player.id) -> Map.put(player, :connected, set_to)
      true -> player
    end
  end
end
