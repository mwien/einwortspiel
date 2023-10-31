defmodule LostinwordsWeb.GameLive.Others do
  use Phoenix.Component

  alias LostinwordsWeb.GameLive.Main

  attr :player_id, :string
  attr :players, :map
  attr :words, :map
  attr :clues, :map
  attr :phase, :atom
  def render(assigns) do
    ~H"""
      <.miniview player={@players[player]} word={@words[player]} clue={Main.get_clue_for_player(@clues, player)} phase={@phase} :for={player <- Map.keys(@players)} :if={player != @player_id}/>
    """
  end

  # TODO: show other stuff as well
  # TODO: maybe only give player name and icon!
  # TODO: show clue only after first phase!
  def miniview(assigns) do
    ~H"""
    <div
      class={"rounded-lg h-16 w-48 border-gray-200
      shadow-md text-xl flex flex-col justify-center font-oswald "}
    >
      <%= @word %>
    </div>
     <Heroicons.ellipsis_horizontal class="ml-1 w-6 h-6 inline
                  duration-2000
                  animate-bounce" :if={@phase == :clues and @clue == ""} />  
     <Heroicons.check_circle class="ml-1 w-6 h-6 inline" :if={@phase == :clues and @clue != ""} />
    <%= @player.name %>  
    <span :if={@phase != :clues}> : <%= @clue %> </span> 
    """
  end

end
