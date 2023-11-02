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
      <Words.render words={get_words_for_player(@round.commonwords, @round.extrawords, @round.shuffle, @player_id)} active={@round.phase == :guesses} show={true} />
      <Clue.render clue={get_clue_for_player(@round.clues, @player_id)} active={@round.phase == :clues} />
      <Others.render player_id={@player_id} players={@players} words={get_words_for_player(@round.commonwords, @round.extrawords, @round.shuffle, @player_id)} clues = {@round.clues} phase = {@round.phase} />
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

  def get_words_for_player(commonwords, extrawords, shuffle, player_id) do
    [extrawords[player_id] | commonwords] 
    |> permute_by(shuffle[player_id])
  end

  def permute_by(list, order) do
    Enum.zip(order, list)
    |> List.keysort(0)
    |> Enum.reduce([], fn {_, l}, acc -> [l | acc] end)
  end
end
