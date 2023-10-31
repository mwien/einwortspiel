defmodule LostinwordsWeb.GameLive.Main do
  use Phoenix.Component

  alias LostinwordsWeb.GameLive.Words
  alias LostinwordsWeb.GameLive.Clue
  alias LostinwordsWeb.GameLive.Others

  attr :round, Lostinwords.Game.Round
  attr :players, :map 
  attr :state, Lostinwords.Game.TableState
  attr :player_id, :string

  def main(assigns) do
    ~H"""
    <div id="game" :if={@state.phase != :init}> 
      <Words.render words={get_words_for_player(@round.commonwords, @round.extrawords, @player_id)} active={@round.phase == :guesses} />
      <Clue.render clue={get_clue_for_player(@round.clues, @player_id)} active={@round.phase == :clues} />
      <Others.render player_id={@player_id} players={@players} words={@round.extrawords} clues = {@round.clues} phase = {@round.phase} />
    </div>
    """
  end

  def get_clue_for_player(clues, player_id) do
    if Map.has_key?(clues, player_id) do
      clues[player_id]
    else 
      ""
    end
  end

  # TODO: do shuffle later
  def get_words_for_player(commonwords, extrawords, player_id) do
    [extrawords[player_id] | commonwords] 
  end
end
