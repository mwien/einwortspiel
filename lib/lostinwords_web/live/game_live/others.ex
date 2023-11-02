defmodule LostinwordsWeb.GameLive.Others do
  use Phoenix.Component

  alias LostinwordsWeb.GameLive.Main
  alias LostinwordsWeb.GameLive.Words

  attr :player_id, :string
  attr :players, :map
  attr :words, :list
  attr :clues, :map
  attr :phase, :atom
  def render(assigns) do
    ~H"""
      <div class="flex justify-center mt-20">
      <.miniview player={@players[player]} words={@words} clue={Main.get_clue_for_player(@clues, player)} phase={@phase} :for={player <- Map.keys(@players)} :if={player != @player_id}/>
      </div>
    """
  end

  # TODO: show other stuff as well
  # TODO: maybe only give player name and icon!
  # TODO: show clue only after first phase!
  def miniview(assigns) do
    ~H"""
      <div>
     <Heroicons.ellipsis_horizontal class="ml-1 w-6 h-6 inline
                  duration-2000
                  animate-bounce" :if={@phase == :clues and @clue == ""} />  
     <Heroicons.check_circle class="ml-1 w-6 h-6 inline" :if={@phase == :clues and @clue != ""} />
      <%= @player.name %>  
      <span :if={@phase != :clues}> : <%= @clue %> </span> 
     <Words.render words={@words} active={false} show={false}/>
      </div>
    """
  end

end
