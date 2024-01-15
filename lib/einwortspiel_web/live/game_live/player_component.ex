defmodule EinwortspielWeb.GameLive.PlayerComponent do
  use EinwortspielWeb, :html

  alias EinwortspielWeb.GameLive.{Words, Clue}
  
  # could also have Name.render?
  # TODO: add Words.render

  def render(assigns) do
    ~H"""
    <.box class="my-2"> 
      <div class="flex justify-between"> 
        <.textform
          id={"nameform"}
          form={to_form(%{"text" => @player.name})}
          submit_handler="set_name"
          :if={@thisplayer}
        /> 
        <.textform_placeholder :if={!@thisplayer}> 
          <%= @player.name %>
        </.textform_placeholder>
        <Clue.render 
          clue={@clue} 
          active={@phase == :clues} 
          :if={@state != :init and (@thisplayer or @phase != :clues)} 
        />
      </div>
    </.box>
    """
  end

  # different functions for ingame beforegame and thisplayer

  # TODO make clue field gray if not active
  # -> do this generally
  # def ingame(assigns) do
  #   ~H"""
  #   <div> 
  #     <div class="flex justify-between"> 
  #       <!-- put helpers stuff in core_comps -->
  #       <Helpers.render_textform
  #         id={"nameform"}
  #         form={to_form(%{"text" => @player.name})}
  #         submit_handler="set_name"
  #       />
  #       <Clue.render 
  #         clue={@clue} 
  #         active={@phase == :clues} 
  #         :if={@thisplayer or @phase != :clues} 
  #       />
  #     </div>
  #     <Words.render 
  #       words={prepare_words(@commonwords, @extraword, @shuffle)} 
  #       active={@phase == :guesses and @thisplayer}
  #       correctword={@extraword}
  #       guess={@guess}
  #       show={@guess != ""}
  #       :if={@thisplayer or @phase == :final}
  #     />
  #   </div>
  #   """
  # end

  # # TODO: add beforegame


  # defp prepare_words(commonwords, extraword, shuffle) do
  #   [extraword | commonwords] 
  #   |> Enum.zip(shuffle)
  #   |> List.keysort(1)
  #   |> Enum.unzip()
  #   |> elem(0)
  # end
end
