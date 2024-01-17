defmodule EinwortspielWeb.GameLive.Greet do
  use EinwortspielWeb, :html 

  # TODO: have generate name option 
  # TODO: move set name here, start with empty name

  def render(assigns) do
    ~H"""
    <.header>
      <h2 class="text-3xl md:text-4xl font-bebasneue m-1"> einwortspiel </h2>
    </.header>
    <.main> 
      <.box class="flex flex-col items-center w-full my-1">
        <.button phx-click="join" class="my-2 py-1.5 px-2" >
          Join
        </.button>
      </.box>
    </.main>
    """
  end
end
