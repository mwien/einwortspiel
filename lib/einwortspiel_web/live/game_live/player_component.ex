defmodule EinwortspielWeb.GameLive.PlayerComponent do
  use EinwortspielWeb, :html

  alias EinwortspielWeb.GameLive.Words

  # TODO: do not pass full state!
  attr :player, Einwortspiel.Game.Player
  attr :thisplayer, :boolean
  attr :state, Einwortspiel.Game.TableState
  attr :clue, :string, default: ""
  attr :phase, :atom, default: nil
  attr :commonwords, :list, default: nil
  attr :extraword, :string, default: nil
  attr :shuffle, :list, default: nil
  attr :guess, :list, default: nil

  def render(assigns) do
    ~H"""
    <.box class={"mt-2" <> if @thisplayer, do: " mb-4", else: " mb-2"}>
      <div class="flex justify-between items-center">
        <.textform
          :if={@thisplayer}
          id="nameform"
          label=""
          form={to_form(%{"text" => @player.name})}
          submit_handler="set_name"
          class="w-4/12"
        />
        <.textform_placeholder :if={!@thisplayer} label="" value={@player.name} class="w-4/12" />
        <.textform
          :if={@thisplayer and @phase == :clues}
          id="clueform"
          label="Clue"
          form={to_form(%{"text" => @clue})}
          submit_handler="submit_clue"
          class="w-6/12"
        />
        <.textform_placeholder
          :if={@state.phase != :init and @phase != :clues}
          label="Clue"
          value={@clue}
          class="w-6/12"
        />
        <.icon
          :if={(@phase == :clues and @clue == nil) or (@phase == :guesses and @guess == nil)}
          name="hero-ellipsis-horizontal"
          class="mx-1 w-4 h-4 md:w-5 md:h-5 duration-2000 animate-bounce"
        />
        <.icon
          :if={(@phase == :clues and @clue != nil) or (@phase == :guesses and @guess != nil)}
          name="hero-check-circle"
          class="mx-1 w-4 h-4 md:w-5 md:h-5"
        />
        <.icon
          :if={@phase == :final}
          name="hero-check-circle"
          class="mx-1 w-4 h-4 md:w-5 md:h-5 invisible"
        />
      </div>
      <Words.render
        :if={@state.phase != :init and (@thisplayer or @phase == :final)}
        words={prepare_words(@commonwords, @extraword, @shuffle)}
        active={@phase == :guesses and @thisplayer}
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
