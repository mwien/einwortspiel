defmodule EinwortspielWeb.GameLive.Ingame do
  use EinwortspielWeb, :html 

  alias EinwortspielWeb.GameLive.PlayerComponent

  def render(assigns) do
    ~H"""
    <.header>
      <h2 class="text-4xl font-bebasneue m-1"> einwortspiel </h2>
      <div class="flex items-center">
        <.button phx-click="start_round" class="px-1 py-0.5 m-1" :if={@state.phase == :end_of_round}> 
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
      <PlayerComponent.render 
        clue={@round.clues[@player_id]}
        phase={@round.phase}
        player={@players[@player_id]}
        thisplayer={true}
        state={@state}
        commonwords={@round.commonwords}
        extraword={@round.extrawords[@player_id]}
        shuffle={@round.shuffle[@player_id]}
        guess={@round.guesses[@player_id]}
      />
      <PlayerComponent.render
        clue={@round.clues[player]}
        phase={@round.phase}
        player={@players[player]}
        thisplayer={false}
        state={@state} 
        commonwords={@round.commonwords}
        extraword={@round.extrawords[player]}
        shuffle={@round.shuffle[player]}
        guess={@round.guesses[player]}
        :for={player <- Map.keys(@players)}
        :if={player != @player_id}
      />
    </.main>
    """ 
  end
end
