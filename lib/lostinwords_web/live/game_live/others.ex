defmodule LostinwordsWeb.GameLive.Others do
  use Phoenix.Component

  alias LostinwordsWeb.GameLive.Main
  alias LostinwordsWeb.GameLive.Words

  attr :player_id, :string
  attr :players, :map
  attr :commonwords, :list 
  attr :extrawords, :map 
  attr :shuffle, :map
  attr :clues, :map
  attr :guesses, :map
  attr :phase, :atom
  def render(assigns) do
    ~H"""
      <div class="flex flex-col items-center mt-20">
        <h3 class="text-xl font-oswald font-bold m-5" > Other Players: </h3>
        <.miniview this_player={@players[player]} words={Main.get_words_for_player(@commonwords, @extrawords, @shuffle, player)} correctword={@extrawords[player]} clue={Main.get_clue_for_player(@clues, player)} guess ={@guesses[player]} phase={@phase} :for={player <- Map.keys(@players)} :if={player != @player_id}/>
      </div>
    """
  end

  # TODO: show other stuff as well
  # TODO: maybe only give player name and icon!
  # TODO: show clue only after first phase!
  def miniview(assigns) do
    ~H"""
      <div class="text-xl font-oswald w-full" >
      <div class="my-2 ml-4"> 
     <Heroicons.ellipsis_horizontal class="mr-1 w-6 h-6 inline
                  duration-2000
                  animate-bounce" :if={(@phase == :clues and @clue == "") or (@phase == :guesses and @guess == nil)} />  
     <Heroicons.check_circle class="mr-1 w-6 h-6 inline" :if={(@phase == :clues and @clue != "") or (@phase == :guesses and @guess != nil)} />
          <%= @this_player.name %> : <%= if @phase != :clues do @clue else "" end %> 
        </div> 
      <Words.render words={@words} active={false} correctword={@correctword} guess={@guess} show={@phase == :final} :if={@phase == :final}/> 
      </div>
    """
  end

end
