defmodule EinwortspielWeb.GameLive.Pregame do
  use EinwortspielWeb, :html 

  # TUDU: change map_size(@players) to correct function counting active players!
  def render(assigns) do
    ~H"""
    <.header>
      <h2 class="text-4xl font-bebasneue m-1"> einwortspiel </h2>
      <.button phx-click="start_round" class="px-1 py-0.5 m-1" :if={map_size(@players) >= 2}> 
        Start 
      </.button>
    </.header> 
    <.main> 
      <.box class="text-center my-1" :if={map_size(@players) < 2}> 
        <p class="m-1">
          At least two players are necessary to start a game
          <.icon 
            name="hero-ellipsis-horizontal"
            class="ml-1.5 w-5 h-5 duration-2000 animate-bounce"
          />
        </p>
      </.box>
      <.box class="text-center my-1" :if={map_size(@players) >= 2}> 
        <p class="m-1">
          Ready to start
          <.icon 
            name="hero-check-circle"
            class="ml-1.5 w-5 h-5"
          />
        </p>
      </.box>
      <.box class="text-center my-1"> 
        <p class="m-1">  
          Share the url to invite other players
          <.button phx-click={JS.dispatch("urlcopy")} class="my-1 ml-1 px-1.5 pb-0.5 group">  
            <.icon name="hero-clipboard-document" class="w-5 h-5 group-focus:hidden"/>
            <.icon name="hero-clipboard-document-check" class="w-5 h-5 hidden group-focus:inline-block"/>
          </.button>
        </p>
      </.box>
      TODO: player components -> just names
    </.main>
    """
  end
end
