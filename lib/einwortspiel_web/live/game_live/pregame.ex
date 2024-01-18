defmodule EinwortspielWeb.GameLive.Pregame do
  use EinwortspielWeb, :html

  alias EinwortspielWeb.GameLive.PlayerComponent

  # TUDU: change map_size(@players) to correct function counting active players!
  def render(assigns) do
    ~H"""
    <.header>
      <.button :if={map_size(@players) >= 2} phx-click="start_round" class="px-1 py-0.5 m-1">
        Start
      </.button>
    </.header>
    <.main>
      <.box class="text-center my-1">
        <p :if={map_size(@players) < 2} class="m-1">
          Waiting for second player
          <.icon name="hero-ellipsis-horizontal" class="ml-1.5 w-5 h-5 duration-2000 animate-bounce" />
        </p>
        <p :if={map_size(@players) >= 2} class="m-1">
          Ready to start <.icon name="hero-check-circle" class="ml-1.5 w-5 h-5" />
        </p>
        <p class="m-1">
          Share the url to invite further players
          <.button phx-click={JS.dispatch("urlcopy")} class="my-1 ml-1 px-1.5 pb-0.5 group">
            <.icon name="hero-clipboard-document" class="w-5 h-5 group-focus:hidden" />
            <.icon
              name="hero-clipboard-document-check"
              class="w-5 h-5 hidden group-focus:inline-block"
            />
          </.button>
        </p>
      </.box>
      <PlayerComponent.render player={@players[@player_id]} thisplayer={true} state={@state} />
      <PlayerComponent.render
        :for={player <- Map.keys(@players)}
        :if={player != @player_id}
        player={@players[player]}
        thisplayer={false}
        state={@state}
      />
    </.main>
    """
  end
end
