defmodule LostinwordsWeb.GameLive.Header do
  use Phoenix.Component 
  
  alias LostinwordsWeb.GameLive.NextRound
  alias LostinwordsWeb.Helpers

  attr :name, :string
  attr :wins, :integer
  attr :losses, :integer
  attr :phase, :atom 
  attr :num_players, :integer

  def header(assigns) do
    ~H"""
    <header class = "p-0.5 bg-blue-50 shadow-md rounded-lg">
      <!--<h2 class="text-2xl font-bebasneue font-bold m-5"> Lost in Words </h2>-->
      <div class= "flex items-center justify-between">
          <Helpers.render_textform
            id="nameform"
            submit_handler="set_name"
            value={@name}
          />
        <div> 
          <span> <Heroicons.plus_circle class="w-5 h-5 mb-1 inline"/> <%= @wins %> </span> 
          <span> <Heroicons.minus_circle class="w-5 h-5 ml-1 mb-1 inline"/> <%= @losses %> </span>
        </div>
        <NextRound.render state={@phase} num_players={@num_players}/>
      </div>
    </header> 
    """
  end
end
