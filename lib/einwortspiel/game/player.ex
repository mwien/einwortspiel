defmodule Einwortspiel.Game.Player do
  alias __MODULE__

  defstruct [
    :name, 
    :connected, 
    :active, # different from local active! which indicates whether spectator in cur. round. this gives whether player wants to be active, e.g. in next round (maybe better name)
  ]

  def init(name) do
    %Player{
      name: name,
      connected: true, # is this fine?
      active: true, # ?
    }
  end
end
