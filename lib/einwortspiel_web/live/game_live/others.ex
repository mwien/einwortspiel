defmodule EinwortspielWeb.GameLive.Others do
  use Phoenix.Component

  alias EinwortspielWeb.GameLive.Main
  alias EinwortspielWeb.GameLive.Words

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
      <div class="flex flex-col items-center">
        <!--<h3 class="font-bold m-5" > Other Players: </h3>-->
        <.miniview this_player={@players[player]} words={Main.get_words_for_player(@commonwords, @extrawords, @shuffle, player)} correctword={@extrawords[player]} clue={Main.get_clue_for_player(@clues, player)} guess ={@guesses[player]} phase={if !Map.has_key?(@extrawords, @player_id) do :final else @phase end} :for={player <- Map.keys(@players)} :if={player != @player_id}/>
      </div>
    """
  end

  # TODO: show other stuff as well
  # TODO: maybe only give player name and icon!
  # TODO: show clue only after first phase!

  # TODO: shifts left in last phase as checkmark disappears
  def miniview(assigns) do
    ~H"""
      <div class="w-full mb-2" >
      <div class="mt-2 mb-4 ml-4"> 
     <Heroicons.ellipsis_horizontal class="mr-1 w-6 h-6 inline
                  duration-2000
                  animate-bounce" :if={(@phase == :clues and @clue == "") or (@phase == :guesses and @guess == nil)} />  
     <Heroicons.check_circle class="mr-1 w-6 h-6 inline" :if={(@phase == :clues and @clue != "") or (@phase == :guesses and @guess != nil)} />
     <Heroicons.check_circle class="mr-1 w-6 h-6 inline" :if={@phase != :clues and @phase != :guesses} />
          <%= @this_player.name <> ": " %> 
          <span class="inline-block bg-white leading-8 min-w-32 py-0.5 px-1 ml-2" :if={@phase != :clues and @clue != ""} > <%= @clue %> </span> 
          <span class="inline-block bg-white leading-8 min-w-32 py-0.5 px-1 ml-2 invisible" :if={@phase != :clues and @clue == ""} > Placeholder </span> 
          <span class="inline-block bg-white leading-8 min-w-32 py-0.5 px-1 ml-2 invisible" :if={@phase == :clues} > Placeholder </span>
        </div> 
      <Words.render words={@words} active={false} correctword={@correctword} guess={@guess} show={@phase == :final} :if={@phase == :final}/> 
      </div>
    """
  end

end
