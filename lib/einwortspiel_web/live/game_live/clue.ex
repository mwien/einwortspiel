defmodule EinwortspielWeb.GameLive.Clue do
  use EinwortspielWeb, :html 

  attr :clue, :string
  attr :active, :boolean

  # use textform placeholder
  def render(assigns) do
    ~H"""
    <.textform
      id={"clueform"}
      label={"Clue"}
      form={to_form(%{"text" => @clue})}
      submit_handler="submit_clue"
      class={"w-7/12"}
      :if={@active}
    />
    <.textform_placeholder 
      label={"Clue"}
      value={@clue}
      class={"w-7/12"}
      :if={!@active}
    />
    """
  end

end
