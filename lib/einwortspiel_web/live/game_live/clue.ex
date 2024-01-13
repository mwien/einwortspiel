defmodule EinwortspielWeb.GameLive.Clue do
  use Phoenix.Component

  alias EinwortspielWeb.Helpers

  attr :clue, :string
  attr :active, :boolean
  # TODO: make if nicer
  def render(assigns) do
    ~H"""
    <div>
      Clue:
      <Helpers.render_textform
        id={"clueform"}
        form={to_form(%{"text" => @clue})}
        submit_handler="submit_clue"
        :if={@active}
      />
      <span class="m-2" :if={!@active}>
        <div class="inline-block text-start rounded-sm w-32 mr-1 py-0.5 px-1 bg-white leading-8"> 
          <%= @clue %> 
        </div>
        <Helpers.render_submit />
      </span>
    </div>
    """
  end

end
