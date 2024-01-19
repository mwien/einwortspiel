defmodule EinwortspielWeb.GameLive.PlayerComponent do
  use EinwortspielWeb, :html

  alias EinwortspielWeb.GameLive.Words

  # TODO: split this up a bit 
  # e.g. -> for each item have phases where its shown and how 
  # then just use a map or something

  attr :thisplayer, :boolean
  attr :player, Einwortspiel.Game.Player
  attr :table_phase, :atom
  attr :round_phase, :atom, default: nil
  attr :commonwords, :list, default: nil
  attr :extraword, :string, default: nil
  attr :shuffle, :list, default: nil
  attr :clue, :string, default: ""
  attr :guess, :list, default: nil

  def render(assigns) do
    ~H"""
    <.box class={"mt-2" <> if @thisplayer, do: " mb-4", else: " mb-2"}>
      <div class="flex justify-between items-center">
        <.textform
          :if={@thisplayer}
          id="nameform"
          form={to_form(%{"text" => @player.name})}
          submit_handler="set_name"
          class="w-4/12"
        />
        <.textform_placeholder :if={!@thisplayer} value={@player.name} class="w-4/12" />
        <.textform
          :if={@thisplayer and @round_phase == :clues}
          id="clueform"
          label="Clue"
          form={to_form(%{"text" => @clue})}
          submit_handler="submit_clue"
          class="w-6/12"
        />
        <.textform_placeholder
          :if={@table_phase != :init and @round_phase != :clues}
          label="Clue"
          value={@clue}
          class="w-6/12"
        />
        <.icon
          :if={(@round_phase == :clues and @clue == nil) or (@round_phase == :guesses and @guess == nil)}
          name="hero-ellipsis-horizontal"
          class="mx-1 w-4 h-4 md:w-5 md:h-5 duration-2000 animate-bounce"
        />
        <.icon
          :if={(@round_phase == :clues and @clue != nil) or (@round_phase == :guesses and @guess != nil)}
          name="hero-check-circle"
          class="mx-1 w-4 h-4 md:w-5 md:h-5"
        />
        <.icon
          :if={@round_phase == :final}
          name="hero-check-circle"
          class="mx-1 w-4 h-4 md:w-5 md:h-5 invisible"
        />
      </div>
      <Words.render
        :if={@table_phase != :init and (@thisplayer or @round_phase == :final)}
        words={prepare_words(@commonwords, @extraword, @shuffle)}
        active={@round_phase == :guesses and @thisplayer}
        correctword={@extraword}
        guess={@guess}
        show={@guess != nil}
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
