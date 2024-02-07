defmodule EinwortspielWeb.GameLive.Greet do
  use EinwortspielWeb, :html

  # TODO: have generate name option 
  # TODO: move set name here, start with empty name

  def render(assigns) do
    ~H"""
    <.box class="flex flex-col items-center my-1">
      <.button phx-click="join" class="my-2 py-1.5 px-2">
        Join
      </.button>
    </.box>
    """
  end
end
