defmodule LostinwordsWeb.GameLive.NextRound do
  use Phoenix.Component

  # may also include setting stuff etc

  def render(assigns) do
    ~H"""
    <%= if @state == :end_of_round do %>
      <div id="nextround" class="m-4">
        <LostinwordsWeb.CoreComponents.button phx-click="start_round">
          Next Round
        </LostinwordsWeb.CoreComponents.button>
      </div>
    <% end %>
    <%= if @state == :init && @num_players >= 2 do %>
      <div>
        <LostinwordsWeb.CoreComponents.button phx-click="start_round">
          Start Round
        </LostinwordsWeb.CoreComponents.button>
      </div>
    <% end %>
    """
  end
end
