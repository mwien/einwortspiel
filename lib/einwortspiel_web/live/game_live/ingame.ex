defmodule EinwortspielWeb.GameLive.Ingame do
  use EinwortspielWeb, :html

  alias EinwortspielWeb.GameLive.PlayerComponent

  # TODO: -> introduce spectator mode -> replace !Map.has_key?(...) below

  attr :player_id, :string
  attr :clues, :map
  attr :guesses, :map
  attr :allwords, :map
  attr :extrawords, :map
  attr :waiting_for, :map
  attr :table_phase, :atom
  attr :round_phase, :atom
  attr :players, :map
  attr :can_start_round, :boolean
  attr :wins, :integer
  attr :losses, :integer

  def render(assigns) do
    ~H"""
    <.header>
      <div class="flex items-center">
        <.button :if={@can_start_round} phx-click="start_round" class="px-1 py-0.5 m-1">
          Next
        </.button>
        <div class="flex items-center mx-1">
          <div class="px-1 py-0.5 bg-green-300 rounded-sm ring ring-violet-700 m-1">
            <%= @wins %>
          </div>
          <div class="px-1 py-0.5 bg-red-400 rounded-sm ring ring-violet-700 m-1">
            <%= @losses %>
          </div>
        </div>
      </div>
    </.header>
    <.main>
      <.box :if={!Map.has_key?(@extrawords, @player_id)} class="my-1 text-center">
        <span class="my-1">
          Spectating current round, you will join starting with the next one!
        </span>
      </.box>
      <.box class="my-1 text-center">
        <span class="my-1"><%= render_info(@round_phase) %></span>
      </.box>
      <PlayerComponent.render
        :if={Map.has_key?(@extrawords, @player_id)}
        thisplayer={true}
        player={@players[@player_id]}
        table_phase={@table_phase}
        round_phase={@round_phase}
        allwords={@allwords[@player_id]}
        extraword={@extrawords[@player_id]}
        waiting={MapSet.member?(@waiting_for, @player_id)}
        clue={@clues[@player_id]}
        guess={@guesses[@player_id]}
      />
      <PlayerComponent.render
        :for={player <- Map.keys(@players)}
        :if={player != @player_id and Map.has_key?(@extrawords, player)}
        thisplayer={false}
        player={@players[player]}
        table_phase={@table_phase}
        round_phase={@round_phase}
        allwords={@allwords[player]}
        extraword={@extrawords[player]}
        waiting={MapSet.member?(@waiting_for, player)}
        clue={@clues[player]}
        guess={@guesses[player]}
      />
    </.main>
    """
  end

  defp render_info(round_phase) do
    case round_phase do
      :clues -> "Describe your words with one clue!"
      :guesses -> "Guess the word that only you have!"
      :win -> "You win the round!"
      :loss -> "You lose the round!"
    end
  end
end
