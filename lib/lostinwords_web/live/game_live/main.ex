defmodule LostinwordsWeb.GameLive.Main do
  use Phoenix.Component

  alias LostinwordsWeb.GameLive.Words
  alias LostinwordsWeb.GameLive.Clue
  alias LostinwordsWeb.GameLive.Others

  attr :round, Lostinwords.Game.Round
  attr :state, Lostinwords.Game.TableState
  attr :player_id, :string
  attr :players, :map

  def main(assigns) do
    ~H"""
    <div id="game" :if={@state.phase != :init}> 
      <Words.render words={get_words_for_player(@round.commonwords, @round.extrawords, @round.shuffle, @player_id)} active={@round.phase == :guesses and @round.guesses[@player_id] == nil} correctword={@round.extrawords[@player_id]} guess={@round.guesses[@player_id]} show = {@round.guesses[@player_id] != nil} :if={Map.has_key?(@round.extrawords, @player_id)} />
      <Clue.render clue={get_clue_for_player(@round.clues, @player_id)} active={@round.phase == :clues} :if={Map.has_key?(@round.extrawords, @player_id)} />
      <Others.render player_id={@player_id} players={Map.filter(@players, fn{key, _} -> Map.has_key?(@round.extrawords, key) end) |> IO.inspect()} commonwords = {@round.commonwords} extrawords = {@round.extrawords} shuffle={@round.shuffle} clues = {@round.clues} guesses = {@round.guesses} phase = {@round.phase} />
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
    IO.inspect(commonwords)
    IO.inspect(extrawords)
    IO.inspect(shuffle)
    IO.inspect(player_id)
    [extrawords[player_id] | commonwords] 
    |> permute_by(shuffle[player_id])
  end

  def permute_by(list, order) do
    IO.inspect(list)
    IO.inspect(order)
    Enum.zip(order, list)
    |> List.keysort(0)
    |> Enum.reduce([], fn {_, l}, acc -> [l | acc] end)
  end
end
