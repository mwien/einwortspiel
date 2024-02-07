defmodule EinwortspielWeb.GameLive.PlayerComponent do
  use EinwortspielWeb, :live_component

  def render(assigns) do
    ~H"""
    <div> 
      <%= @player %> 
    </div>
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
