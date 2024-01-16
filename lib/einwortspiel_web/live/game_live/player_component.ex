defmodule EinwortspielWeb.GameLive.PlayerComponent do
  use EinwortspielWeb, :html

  alias EinwortspielWeb.GameLive.{Words, Clue}
  

  # TODO: have clue/name/words in here?

  # could also have Name.render?
  # TODO: add Words.render

  # TODO: do not pass full state!
  attr :player, Einwortspiel.Game.Player 
  attr :thisplayer, :boolean
  attr :state, :atom
  attr :clue, :string, default: ""
  attr :phase, :atom, default: nil 
  attr :commonwords, :list, default: nil
  attr :extraword, :string, default: nil
  attr :shuffle, :list, default: nil 
  attr :guess, :list, default: nil

  def render(assigns) do
    ~H"""
    <.box class="my-2"> 
      <div class="flex justify-between"> 
        <.textform
          id={"nameform"}
          label={""}
          form={to_form(%{"text" => @player.name})}
          submit_handler="set_name"
          class={"w-4/12"}
          :if={@thisplayer}
        /> 
        <.textform_placeholder 
          label={""} 
          value={@player.name}
          class={"w-4/12"}
          :if={!@thisplayer}
        /> 
        <Clue.render 
          clue={@clue} 
          active={@phase == :clues} 
          :if={@state.phase != :init and (@thisplayer or @phase != :clues)} 
        />
      </div>
      <Words.render 
        words={prepare_words(@commonwords, @extraword, @shuffle)} 
        active={@phase == :guesses and @thisplayer}
        correctword={@extraword}
        guess={@guess}
        show={@guess != nil}
        :if={@state.phase != :init and (@thisplayer or @phase == :final)}
      />
    </.box>
    """
  end

  defp prepare_words(commonwords, extraword, shuffle) do
    [extraword | commonwords] 
    |> Enum.zip(shuffle)
    |> List.keysort(1)
    |> Enum.unzip()
    |> elem(0)
  end
end
