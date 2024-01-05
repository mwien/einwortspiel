defmodule EinwortspielWeb.GameLive.Header do
  use Phoenix.Component 
  
  alias EinwortspielWeb.GameLive.NextRound
  alias EinwortspielWeb.Helpers

  attr :name, :string
  attr :wins, :integer
  attr :losses, :integer
  attr :phase, :atom 
  attr :num_players, :integer

  def header(assigns) do
    ~H"""
    <header class = "p-0.5 bg-violet-200 shadow-md rounded-sm">
      <!--<h2 class="text-2xl font-bebasneue font-bold m-5"> Lost in Words </h2>-->
      <div class= "flex items-center justify-between">
          <Helpers.render_textform
            id={"nameform"}
            form={to_form(%{"text" => @name})}
            submit_handler="set_name"
          />
        <div class = "bg-white rounded-sm py-0.5 px-1 leading-8"> 
          <span> <Heroicons.plus_circle class="w-5 h-5 mb-1 inline"/> <%= @wins %> </span> 
          <span> <Heroicons.minus_circle class="w-5 h-5 ml-1 mb-1 inline"/> <%= @losses %> </span>
        </div>
        <NextRound.render state={@phase} num_players={@num_players}/>
      </div>
    </header> 
    """
  end
end
