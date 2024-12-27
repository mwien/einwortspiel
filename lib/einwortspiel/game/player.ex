defmodule Einwortspiel.Game.Player do
  alias __MODULE__

  defstruct [
    :name,
    :connected,
    # active indicates whether player wants to play next round (irrespective whether she is currently playing)
    :active
  ]

  def create(name) do
    %Player{
      name: name,
      connected: true,
      active: true
    }
  end

  def get_name(player), do: player.name
  def get_connected(player), do: player.connected
  def get_active(player), do: player.active

  def set_active(player, val), do: %Player{player | active: val}
  def set_connected(player, val), do: %Player{player | connected: val}
end
