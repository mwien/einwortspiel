defmodule EinwortspielWeb.GameLive.Ingame do
  use EinwortspielWeb, :html 

  alias EinwortspielWeb.GameLive.PlayerComponent

  def render(assigns) do
    ~H"""
    <.header>
      <h2 class="text-4xl font-bebasneue m-1"> einwortspiel </h2>
      <div class="flex items-center">
        <.button phx-click="start_round" class="px-1 py-0.5 m-1" :if={@state == :end_of_round}> 
          Next
        </.button>
        <.inner_box class="m-1">
          <span> 
            <.icon name="hero-plus-circle" class="mb-1"/> 
            <%= @state.wins %> 
          </span> 
          <span> 
            <.icon name="hero-minus-circle" class="mb-1"/> 
            <%= @state.losses %> 
          </span>
        </.inner_box>
      </div>
    </.header> 
    <.main> 
      TODO player components -> first own then others
      <PlayerComponent.render 
        clue={@round.clues[@player_id]}
        phase={@round.phase}
        player={@players[@player_id]}
        thisplayer={true}
        state={@state}
      />
      <PlayerComponent.render
        clue={@round.clues[player]}
        phase={@round.phase}
        player={@players[player]}
        thisplayer={false}
        state={@state}
        :for={player <- Map.keys(@players)}
        :if={player != @player_id}
      />
    </.main>
    """ 
  end
end
