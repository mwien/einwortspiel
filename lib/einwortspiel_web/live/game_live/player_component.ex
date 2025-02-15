defmodule EinwortspielWeb.GameLive.PlayerComponent do
  use EinwortspielWeb, :live_component

  attr :id, :string
  attr :player, :map
  attr :this_player, :boolean
  attr :spectating, :boolean
  attr :phase, :atom

  def render(%{player: %{words: nil}} = assigns) do
    ~H"""
    <div>
      <.box class="mt-2 mb-4">
        <div class="flex justify-between items-center mb-1">
          <.name name={@player.name} gray_out={!@player.connected} />
          <.icon name="hero-check-circle" class="m-1 w-4 h-4 md:w-5 md:h-5 invisible self-start" />
        </div>
        <div :if={@phase != :init} class="text-center mb-1">Joining next round!</div>
      </.box>
    </div>
    """
  end

  def render(%{this_player: true} = assigns) do
    ~H"""
    <div>
      <.box class="mt-2 mb-4">
        <div class="flex justify-between items-center mb-1">
          <.name name={@player.name} gray_out={!@player.connected} />
          <.icon
            :if={
              (@phase == :clues and @player.clue == nil) or
                (@phase == :guesses and @player.guess == nil)
            }
            name="hero-ellipsis-horizontal"
            class="m-1 w-4 h-4 md:w-5 md:h-5 duration-2000 animate-bounce self-start"
          />
          <.icon
            :if={
              (@phase == :clues and @player.clue != nil) or
                (@phase == :guesses and @player.guess != nil)
            }
            name="hero-check-circle"
            class="m-1 w-4 h-4 md:w-5 md:h-5 self-start"
          />
          <.icon
            :if={@phase == :win or @phase == :loss}
            name="hero-check-circle"
            class="m-1 w-4 h-4 md:w-5 md:h-5 invisible self-start"
          />
        </div>
        <div class="flex flex-row justify-center mb-2">
          <.textform
            :if={@phase == :clues and @player.clue == nil}
            id="clueform"
            label="Clue"
            form={to_form(%{"text" => @player.clue})}
            submit_handler="submit_clue"
            class="w-8/12 md:w-7/12 lg:w-6/12"
          />
          <.textform_placeholder
            :if={@phase != :init and (@phase != :clues or @player.clue != nil)}
            label="Clue"
            value={@player.clue}
            class="w-8/12 md:w-7/12 lg:w-6/12"
          />
        </div>
        <.words
          :if={@player.words != nil}
          words={@player.words}
          guess={@player.guess}
          phase={@phase}
          spectating={@spectating}
        />
      </.box>
    </div>
    """
  end

  def render(%{this_player: false} = assigns) do
    ~H"""
    <div>
      <.box class="my-2">
        <div class="flex justify-between items-center mb-1">
          <.name name={@player.name} gray_out={!@player.connected} />
          <.icon
            :if={
              (@phase == :clues and @player.clue == nil) or
                (@phase == :guesses and @player.guess == nil)
            }
            name="hero-ellipsis-horizontal"
            class="m-1 w-4 h-4 md:w-5 md:h-5 duration-2000 animate-bounce self-start"
          />
          <.icon
            :if={
              (@phase == :clues and @player.clue != nil) or
                (@phase == :guesses and @player.guess != nil)
            }
            name="hero-check-circle"
            class="m-1 w-4 h-4 md:w-5 md:h-5 self-start"
          />
          <.icon
            :if={@phase == :win or @phase == :loss}
            name="hero-check-circle"
            class="m-1 w-4 h-4 md:w-5 md:h-5 self-start invisible"
          />
        </div>
        <div class="flex flex-row justify-center mb-2">
          <.textform_placeholder
            :if={(@phase != :init and @phase != :clues) or @spectating}
            label="Clue"
            value={@player.clue}
            class="w-8/12 md:w-7/12 lg:w-6/12"
          />
        </div>
        <.words
          :if={@phase == :win or @phase == :loss or @spectating}
          words={@player.words}
          guess={@player.guess}
          phase={@phase}
          spectating={@spectating}
        />
      </.box>
    </div>
    """
  end

  attr :name, :string
  attr :gray_out, :boolean

  defp name(assigns) do
    ~H"""
    <div class={
      ["self-start", "px-0.5"] ++
        [if(@gray_out, do: "text-slate-500")]
    }>
      <%= @name %>
    </div>
    """
  end

  attr :words, :list
  attr :guess, :string
  attr :phase, :atom
  attr :spectating, :boolean

  defp words(assigns) do
    ~H"""
    <div class="flex justify-center mb-2 mt-4 mx-1">
      <.word
        :for={word <- @words}
        word={elem(word, 0)}
        extraword={elem(word, 1)}
        guess={@guess}
        active={@phase == :guesses and @guess == nil and !@spectating}
      />
    </div>
    """
  end

  attr :word, :string
  attr :extraword, :boolean
  attr :guess, :string
  attr :active, :boolean

  defp word(assigns) do
    ~H"""
    <button
      phx-click="submit_guess"
      value={@word}
      class={[
        "rounded-sm h-24 w-48 shadow-md flex flex-col justify-center items-center font-bebasneue text-xl md:text-2xl",
        (@guess != @word and (@guess == nil or !@extraword)) && "bg-white",
        @guess == @word && "ring ring-inset ring-violet-500",
        (@guess != nil and @extraword) && "bg-green-300",
        (@guess == @word and !@extraword) && "bg-red-400"
      ]}
      disabled={!@active}
    >
      <%= @word %>
    </button>
    """
  end
end
