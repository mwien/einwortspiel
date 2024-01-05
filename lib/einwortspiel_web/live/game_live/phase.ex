defmodule EinwortspielWeb.GameLive.NextRound do
  use Phoenix.Component

  # TODO: clean up

  # may also include setting stuff etc

  def render(assigns) do
    ~H"""
    <%= if @state == :end_of_round do %>
      <div id="nextround" class="m-2">
        <EinwortspielWeb.CoreComponents.button phx-click="start_round" class = "px-1.5 py-1">
          Next
        </EinwortspielWeb.CoreComponents.button>
      </div>
    <% end %>
    <%= if @state == :init && @num_players >= 2 do %>
      <div class="m-2">
        <EinwortspielWeb.CoreComponents.button phx-click="start_round" class = "px-1.5 py-1">
          Start
        </EinwortspielWeb.CoreComponents.button>
      </div>
    <% end %>
    <%= if (@state == :init and @num_players < 2) or (@state != :init and @state != :end_of_round ) do %>
      <div class="m-2">
        <EinwortspielWeb.CoreComponents.button phx-click="start_round" {%{disabled: "true"}} class = "px-1.5 py-1">
          Start
        </EinwortspielWeb.CoreComponents.button>
      </div>
    <% end %>
    """
  end
end
