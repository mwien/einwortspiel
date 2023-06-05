defmodule LostinwordsWeb.GameLive.NextRound do
  use Phoenix.Component

  # may also include setting stuff etc

  def render(assigns) do
    ~H"""
    <%= if @phase == "final" do %>
      <div id="nextround" class="m-4">
        <LostinwordsWeb.CoreComponents.button phx-click="start_round">
          Next Round
        </LostinwordsWeb.CoreComponents.button>
      </div>
    <% end %>
    <%= if @phase == "not_started" && @num_players >= 2 do %>
      <div>
        <LostinwordsWeb.CoreComponents.button phx-click="start_round">
          Start Round
        </LostinwordsWeb.CoreComponents.button>
      </div>
    <% end %>
    <%= if Enum.member?(["clues", "guesses"], @phase) && @continue do %>
      <div>
        <LostinwordsWeb.CoreComponents.button phx-click="force_continue">
          Continue
        </LostinwordsWeb.CoreComponents.button>
      </div>
    <% end %>
    """
  end
end
