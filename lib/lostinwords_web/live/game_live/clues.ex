defmodule LostinwordsWeb.GameLive.Clues do
  use Phoenix.Component

  alias LostinwordsWeb.Helpers

  def render(assigns) do
    ~H"""
    <div class="text-center text-xl font-oswald m-4">
      <%= for player_id <- @cluers do %>
        <span>
          <%= player_id %>:
          <%= if player_id == @player_id and @phase == "clues" do %>
            <Helpers.render_textform
              id="clueform"
              submit_handler="submit_clue"
              value={
                if Map.has_key?(@clues, @player_id) do
                  @clues[@player_id]
                else
                  ""
                end
              }
            />
          <% else %>
            <%= if @phase == "clues" do %>
              <%= if Map.has_key?(@clues, player_id) do %>
                <%= "clue submitted" %>
              <% else %>
                <Heroicons.ellipsis_horizontal class="ml-1 w-6 h-6 inline
                duration-2000
                animate-bounce" />
              <% end %>
            <% else %>
              <%= @clues[player_id] %>
            <% end %>
          <% end %>
        </span>
      <% end %>
    </div>
    """
  end

  # revive this function
  # defp render_clue(assigns) do
  # end
end
