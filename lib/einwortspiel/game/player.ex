defmodule Einwortspiel.Game.Player do
  alias __MODULE__

  defstruct [
    :name, 
    :connected, 
    :active, # different from local active! which indicates whether spectator in cur. round. this gives whether player wants to be active, e.g. in next round (maybe better name)
  ]

  # TODO: add update functions

  def create(name) do
    %Player{
      name: name,
      connected: true, # is this fine?
      active: true, # ?
    }
  end

  def get_name(player), do: player.name
  def get_active(player), do: player.active
  def get_connected(player), do: player.connected 
end
