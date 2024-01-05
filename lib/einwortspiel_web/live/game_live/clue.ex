defmodule EinwortspielWeb.GameLive.Clue do
  use Phoenix.Component

  alias EinwortspielWeb.Helpers

  attr :clue, :string
  attr :active, :boolean
  # TODO: make if nicer
  def render(assigns) do
    ~H"""
    <div class="text-center flex flex-col justify-center">
      <span>
        Your clue:
        <%= if @active do %>
          <Helpers.render_textform
            id={"clueform"}
            form={to_form(%{"text" => @clue})}
            submit_handler="submit_clue"
          />
        <% else %>
          <div class="inline-block m-2">
            <div class="inline-block text-start rounded-sm w-32 mr-1 py-0.5 px-1 bg-white leading-8"> 
              <span class="inline-block"> <%= @clue %> </span>
            </div>
            <Helpers.render_submit />
          </div>
        <% end %>
      </span>
    </div>
    """
  end

end
