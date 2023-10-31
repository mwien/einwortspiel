defmodule LostinwordsWeb.GameLive.Clue do
  use Phoenix.Component

  alias LostinwordsWeb.Helpers

  attr :clue, :string
  attr :active, :boolean
  # TODO: make if nicer
  def render(assigns) do
    ~H"""
    <div class="text-center text-xl font-oswald m-4">
      <span>
        Your clue:
        <%= if @active do %>
          <Helpers.render_textform
            id="clueform"
            submit_handler="submit_clue"
            value={@clue}
          />
        <% else %>
          <%= @clue %>
        <% end %>
      </span>
    </div>
    """
  end

end
