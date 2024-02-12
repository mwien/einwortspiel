defmodule EinwortspielWeb.GameLive.PlayerComponent do
  use EinwortspielWeb, :live_component

  attr :player, :map 
  attr :phase, :atom
  def render(%{this_player: true} = assigns) do
    ~H"""
    <div> 
      <.box class="mt-2 mb-4">
        <div class="flex justify-between items-center">
          <.textform_placeholder value={@player.name} class="w-4/12" />
          <.textform
            :if={@phase == :clues and @player.clue == nil}
            id="clueform"
            label="Clue"
            form={to_form(%{"text" => @player.clue})}
            submit_handler="submit_clue"
            class="w-6/12"
          />
          <.textform_placeholder
            :if={@phase != :init and (@phase != :clues or @player.clue != nil)}
            label="Clue"
            value={@player.clue}
            class="w-6/12"
          />
         <.icon
           :if={(@phase == :clues and @player.clue == nil) or (@phase == :guesses and @player.guess == nil)}
           name="hero-ellipsis-horizontal"
           class="mx-1 w-4 h-4 md:w-5 md:h-5 duration-2000 animate-bounce"
         />
         <.icon :if={(@phase == :clues and @player.clue != nil) or (@phase == :guesses and @player.guess != nil)} name="hero-check-circle" class="mx-1 w-4 h-4 md:w-5 md:h-5" />
         <.icon
           :if={@phase == :win or @phase == :loss}
           name="hero-check-circle"
           class="mx-1 w-4 h-4 md:w-5 md:h-5 invisible"
         />
        </div>
        <.words words={@player.words} guess={@player.guess} phase={@phase} :if={@player.words != nil} />
      </.box>
    </div>
    """
  end
  
  def render(%{this_player: false} = assigns) do
    ~H"""
    <div> 
      <.box class="my-2">
        <div class="flex justify-between items-center">
          <.textform_placeholder value={@player.name} class="w-4/12" />
          <.textform_placeholder
            :if={@phase != :init and @phase != :clues}
            label="Clue"
            value={@player.clue}
            class="w-6/12"
          />
          <.icon
            :if={(@phase == :clues and @player.clue == nil) or (@phase == :guesses and @player.guess == nil)}
            name="hero-ellipsis-horizontal"
            class="mx-1 w-4 h-4 md:w-5 md:h-5 duration-2000 animate-bounce"
          />
          <.icon :if={(@phase == :clues and @player.clue != nil) or (@phase == :guesses and @player.guess != nil)} name="hero-check-circle" class="mx-1 w-4 h-4 md:w-5 md:h-5" />
          <.icon
            :if={@phase == :win or @phase == :loss}
            name="hero-check-circle"
            class="mx-1 w-4 h-4 md:w-5 md:h-5 invisible"
           />
        </div>
        <.words words={@player.words} guess={@player.guess} phase={@phase} :if={@phase == :win or @phase == :loss} />
      </.box>
    </div>
    """
  end

  attr :words, :list 
  attr :guess, :string
  attr :phase, :atom
  defp words(assigns) do
    ~H"""
    <div class="flex justify-center my-2 mx-1">
      <.word 
        :for={word <- @words}
        word={elem(word, 0)}
        extraword={elem(word, 1)}
        guess={@guess}
        active={@phase == :guesses and @guess != nil}
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
      disable={@active}
    >
      <%= @word %> 
    </button>
    """
  end

  # alias EinwortspielWeb.GameLive.Words

  # TUDU: make render nicer
  # TUDU: maybe win/loss icon

  # attr :thisplayer, :boolean
  # attr :player, Einwortspiel.Game.Player
  # attr :table_phase, :atom
  # attr :round_phase, :atom, default: nil
  # attr :allwords, :list, default: nil
  # attr :extraword, :string, default: nil
  # attr :waiting, :boolean, default: nil
  # attr :clue, :string, default: nil
  # attr :guess, :list, default: nil

  # def render(assigns) do
  #   ~H"""
  #   <.box class={"mt-2" <> if @thisplayer, do: " mb-4", else: " mb-2"}>
  #     <div class="flex justify-between items-center">
  #       <.textform
  #         :if={@thisplayer}
  #         id="nameform"
  #         form={to_form(%{"text" => @player.name})}
  #         submit_handler="set_name"
  #         class="w-4/12"
  #       />
  #       <.textform_placeholder :if={!@thisplayer} value={@player.name} class="w-4/12" />
  #       <.textform
  #         :if={@thisplayer and @round_phase == :clues and @clue == nil}
  #         id="clueform"
  #         label="Clue"
  #         form={to_form(%{"text" => @clue})}
  #         submit_handler="submit_clue"
  #         class="w-6/12"
  #       />
  #       <.textform_placeholder
  #         :if={(@table_phase != :init and @round_phase != :clues) or (@round_phase == :clues and @clue != nil and @thisplayer)}
  #         label="Clue"
  #         value={@clue}
  #         class="w-6/12"
  #       />
  #       <.icon
  #         :if={@waiting == true and @table_phase != :end_of_round}
  #         name="hero-ellipsis-horizontal"
  #         class="mx-1 w-4 h-4 md:w-5 md:h-5 duration-2000 animate-bounce"
  #       />
  #       <.icon :if={@waiting == false and @table_phase != :end_of_round} name="hero-check-circle" class="mx-1 w-4 h-4 md:w-5 md:h-5" />
  #       <.icon
  #         :if={@round_phase == :win or @round_phase == :loss}
  #         name="hero-check-circle"
  #         class="mx-1 w-4 h-4 md:w-5 md:h-5 invisible"
  #       />
  #     </div>
  #     <Words.render
  #       :if={@table_phase != :init and (@thisplayer or @round_phase == :final)}
  #       words={@allwords}
  #       active={@round_phase == :guesses and @thisplayer}
  #       correctword={@extraword}
  #       guess={@guess}
  #       show={@guess != nil}
  #     />
  #   </.box>
  #   """
  # end
end
