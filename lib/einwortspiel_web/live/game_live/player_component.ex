defmodule EinwortspielWeb.GameLive.PlayerComponent do
  use EinwortspielWeb, :html

  alias EinwortspielWeb.GameLive.{Words, Clue}
  
  # different functions for ingame beforegame and thisplayer

  # TODO make clue field gray if not active
  # -> do this generally
  def ingame(assigns) do
    ~H"""
    <div> 
      <div class="flex justify-between"> 
        <%= @player.name %>
        <Clue.render 
          clue={@clue} 
          active={@phase == :clues} 
          :if={@thisplayer or @phase != :clues} 
        />
      </div>
      <Words.render 
        words={prepare_words(@commonwords, @extraword, @shuffle)} 
        active={@phase == :guesses and @thisplayer}
        correctword={@extraword}
        guess={@guess}
        show={@guess != ""}
        :if={@thisplayer or @phase == :final}
      />
    </div>
    """
  end

  # TODO: add beforegame


  defp prepare_words(commonwords, extraword, shuffle) do
    [extraword | commonwords] 
    |> Enum.zip(shuffle)
    |> List.keysort(1)
    |> Enum.unzip()
    |> elem(0)
  end
end
