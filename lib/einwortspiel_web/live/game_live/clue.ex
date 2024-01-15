defmodule EinwortspielWeb.GameLive.Clue do
  use EinwortspielWeb, :html 

  attr :clue, :string
  attr :active, :boolean

  # use textform placeholder
  def render(assigns) do
    ~H"""
    <div>
      Clue:
      <.textform
        id={"clueform"}
        form={to_form(%{"text" => @clue})}
        submit_handler="submit_clue"
        :if={@active}
      />
      <.textform_placeholder :if={!@active}>
        <%= @clue %> 
      </.textform_placeholder>
    </div>
    """
  end

end
