defmodule EinwortspielWeb.GameLive.Greet do
  use EinwortspielWeb, :html 

  # TODO: have generate name option 
  # TODO: move set name here, start with empty name
  # TODO: maybe have grow for main => not centered vertically

  def render(assigns) do
    ~H"""
    <.header>
      <h2 class="text-4xl font-bebasneue m-1"> einwortspiel </h2>
    </.header>
    <.main> 
      <.box class="flex flex-col items-center w-full">
        <.button phx-click="join" class="my-2 py-1.5 px-2" >
          Join
        </.button>
      </.box>
    </.main>
    """
  end
end
