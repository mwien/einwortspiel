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
    <div class="flex justify-center font-oswald text-xl" :if={@state.phase == :init}> 
      Not started yet. 
    </div>

    <div id="game" :if={@state.phase != :init}> 
      <div class="flex justify-center mt-2 mb-6 font-oswald"> 
        <Heroicons.ellipsis_horizontal class="mr-1 w-6 h-6 inline
                  duration-2000
                  animate-bounce" :if={(@round.phase == :clues and get_clue_for_player(@round.clues, @player_id) == "") or (@round.phase == :guesses and @round.guesses[@player_id] == nil)} />  
        <Heroicons.check_circle class="mr-1 w-6 h-6 inline" :if={(@round.phase == :clues and get_clue_for_player(@round.clues, @player_id) != "") or (@round.phase == :guesses and @round.guesses[@player_id] != nil)} />
        <%= case @round.phase do 
          :clues -> "Describe your words with one clue."
          :guesses -> "Guess the word not described by the other clues."
          _ -> "You " <> if @round.guesses == @round.extrawords do "win" else "lose" end  <> " the round."
        end
        %>
      </div>
      <Words.render words={get_words_for_player(@round.commonwords, @round.extrawords, @round.shuffle, @player_id)} active={@round.phase == :guesses and @round.guesses[@player_id] == nil} correctword={@round.extrawords[@player_id]} guess={@round.guesses[@player_id]} show = {@round.guesses[@player_id] != nil} :if={Map.has_key?(@round.extrawords, @player_id)} />
      <Clue.render clue={get_clue_for_player(@round.clues, @player_id)} active={@round.phase == :clues} :if={Map.has_key?(@round.extrawords, @player_id)} />
      <Others.render player_id={@player_id} players={Map.filter(@players, fn{key, value} -> Map.has_key?(@round.extrawords, key) and value.spectator == false end)} commonwords = {@round.commonwords} extrawords = {@round.extrawords} shuffle={@round.shuffle} clues = {@round.clues} guesses = {@round.guesses} phase = {@round.phase} />
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
