defmodule EinwortspielWeb.GameLive.Ingame do
  use EinwortspielWeb, :html 

  alias EinwortspielWeb.GameLive.PlayerComponent

  def render(assigns) do
    ~H"""
    <.header>
      <div class="flex items-center">
        <.button phx-click="start_round" class="px-1 py-0.5 m-1" :if={@state.phase == :end_of_round}> 
          Next
        </.button>
        <div class="flex items-center mx-1">
          <div class="px-1 py-0.5 bg-green-300 rounded-sm ring ring-violet-700 m-1">
            <%= @state.wins %>
          </div>
          <div class="px-1 py-0.5 bg-red-400 rounded-sm ring ring-violet-700 m-1">
            <%= @state.losses %>
          </div>
        </div>
      </div>
    </.header> 
    <.main> 
      <.box class="my-1 text-center" :if={!Map.has_key?(@round.extrawords, @player_id)}>
        <span class="my-1"> Spectating current round, you will join starting with the next one! </span>  
      </.box>
      <.box class="my-1 text-center" :if={@round.phase == :clues}>
        <span class="my-1"> Describe your words with one clue! </span> 
      </.box>
      <.box class="my-1 text-center" :if={@round.phase == :guesses}>
        <span class="my-1"> Guess the word that only you have! </span> 
      </.box>
      <.box class="my-1 text-center" :if={@round.phase == :final}>
        <span class="my-1" :if={@round.guesses == @round.extrawords}> You win the round! </span> 
        <span class="my-1" :if={@round.guesses != @round.extrawords}> You lose the round! </span> 
      </.box>
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
        :if={Map.has_key?(@round.extrawords, @player_id)}
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
        :if={player != @player_id and Map.has_key?(@round.extrawords, player)}
      />
    </.main>
    """ 
  end
end
