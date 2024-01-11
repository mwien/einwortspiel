defmodule EinwortspielWeb.GameLive.Header do
  use Phoenix.Component 
  
  alias EinwortspielWeb.GameLive.NextRound
  alias EinwortspielWeb.Helpers

  attr :player_id, :string
  attr :players, :map
  attr :state, :map
  # TODO: header height different from index page!
  # TODO: on mobile just show title help (?) and settings or something like this -> mobile vs pc header
  def header(assigns) do
    ~H"""
    <header class="flex justify-between p-0.5 bg-violet-200 shadow-md rounded-sm w-11/12 lg:w-3/5 2xl:w-1/2 mx-auto">
      <!--
      <Helpers.render_textform
        id={"nameform"}
        form={to_form(%{"name" => @name})}
        submit_handler="set_name"
      />
      -->
      <div class = "bg-white rounded-sm py-0.5 px-1 leading-8"> 
        <span> <Heroicons.plus_circle class="w-5 h-5 mb-1 inline"/> <%= @state.wins %> </span> 
        <span> <Heroicons.minus_circle class="w-5 h-5 ml-1 mb-1 inline"/> <%= @state.losses %> </span>
      </div>
      <h2 class="text-4xl font-bebasneue font-bold"> einwortspiel </h2>
      <NextRound.render state={@state.phase} num_players={map_size(@players)}/>
    </header> 
    """
  end
end
