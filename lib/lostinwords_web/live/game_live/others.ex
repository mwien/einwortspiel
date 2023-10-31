defmodule LostinwordsWeb.GameLive.Others do
  use Phoenix.Component

  attr :player_id, :string
  attr :players, :map
  def render(assigns) do
    ~H"""
      <.miniview player={@players[player]} :for={player <- Map.keys(@players)} :if={player != @player_id}/>
    """
  end

  # TODO: show other stuff as well
  def miniview(assigns) do
    ~H"""
    <%= @player.name %>
    """
  end

end
