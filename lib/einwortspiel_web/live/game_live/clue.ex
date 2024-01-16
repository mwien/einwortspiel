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
    >
      <.icon 
        name="hero-ellipsis-horizontal"
        class="mx-2 w-4 h-4 md:w-5 md:h-5 duration-2000 animate-bounce"
      />
    </.textform_placeholder>
    """
  end

end
