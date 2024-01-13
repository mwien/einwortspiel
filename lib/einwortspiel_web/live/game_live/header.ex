defmodule EinwortspielWeb.GameLive.Header do
  use EinwortspielWeb, :html
  
  alias EinwortspielWeb.GameLive.NextRound
  alias EinwortspielWeb.Helpers

  # TODO: maybe this should be component which has a slot

  # TODO: use heroicons through icon from core_components

  attr :player_id, :string
  attr :players, :map
  attr :state, :map
  # TODO: on mobile just show title help (?) and settings or something like this -> mobile vs pc header
  # have standings nextround heading ? settings
  # on mobile idk what fits -> without heading
  # TODO: call this header with empty stuff from dead view index
  def render(assigns) do
    ~H"""
    <header class="flex justify-between items-center p-0.5 bg-violet-200 shadow-md rounded-sm w-11/12 lg:w-3/5 2xl:w-1/2 mx-auto">
      <!--
      TODO: put this in rendering of player stuff
      TODO: instead of Helpers -> put in core_comps!!!
      <Helpers.render_textform
        id={"nameform"}
        form={to_form(%{"name" => @name})}
        submit_handler="set_name"
      />
      -->
      <div class = "bg-white rounded-sm p-0.5 m-1"> 
        <span> <Heroicons.plus_circle class="w-5 h-5 mb-1 inline"/> <%= @state.wins %> </span> 
        <span> <Heroicons.minus_circle class="w-5 h-5 ml-1 mb-1 inline"/> <%= @state.losses %> </span>
      </div>
      <!-- make this a function in this module -->
      <NextRound.render state={@state.phase} num_players={map_size(@players)}/>
      <h2 class="text-4xl font-bebasneue m-1"> einwortspiel </h2>
      <!-- make button -->
      <Heroicons.question_mark_circle class="w-5 h-5"/>
      <.icon name="hero-cog-6-tooth" />
      <Heroicons.cog_6_tooth class="w-5 h-5"/>
    </header> 
    """
  end
end
