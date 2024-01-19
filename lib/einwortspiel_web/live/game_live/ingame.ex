defmodule EinwortspielWeb.GameLive.Ingame do
  use EinwortspielWeb, :html

  alias EinwortspielWeb.GameLive.PlayerComponent
  
  # TODO: map phase to string -> only one call of box with lookup

  attr :player_id, :string 
  attr :players, :map 
  attr :round, Einwortspiel.Game.Round
  attr :state, Einwortspiel.Game.TableState

  def render(assigns) do
    ~H"""
    <.header>
      <div class="flex items-center">
        <.button :if={@state.phase == :end_of_round} phx-click="start_round" class="px-1 py-0.5 m-1">
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
      <.box :if={!Map.has_key?(@round.extrawords, @player_id)} class="my-1 text-center">
        <span class="my-1">
           Spectating current round, you will join starting with the next one! 
        </span>
      </.box>
      <.box :if={@round.phase == :clues} class="my-1 text-center">
        <span class="my-1"> Describe your words with one clue! </span>
      </.box>
      <.box :if={@round.phase == :guesses} class="my-1 text-center">
        <span class="my-1"> Guess the word that only you have! </span>
      </.box>
      <.box :if={@round.phase == :final} class="my-1 text-center">
        <span :if={@round.guesses == @round.extrawords} class="my-1"> You win the round! </span>
        <span :if={@round.guesses != @round.extrawords} class="my-1"> You lose the round! </span>
      </.box>
      <PlayerComponent.render
        :if={Map.has_key?(@round.extrawords, @player_id)}
        thisplayer={true}
        player={@players[@player_id]}
        table_phase={@state.phase}
        round_phase={@round.phase}
        commonwords={@round.commonwords}
        extraword={@round.extrawords[@player_id]}
        shuffle={@round.shuffle[@player_id]}
        clue={@round.clues[@player_id]}
        guess={@round.guesses[@player_id]}
      />
      <PlayerComponent.render
        :for={player <- Map.keys(@players)}
        :if={player != @player_id and Map.has_key?(@round.extrawords, player)}
        thisplayer={false}
        player={@players[player]}
        table_phase={@state.phase}
        round_phase={@round.phase}
        commonwords={@round.commonwords}
        extraword={@round.extrawords[player]}
        shuffle={@round.shuffle[player]}
        clue={@round.clues[player]}
        guess={@round.guesses[player]}
      />
    </.main>
    """
  end
end
