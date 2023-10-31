defmodule LostinwordsWeb.GameLive.Header do
  alias LostinwordsWeb.GameLive.NextRound
  use Phoenix.Component 

  attr :name, :string
  attr :wins, :integer
  attr :losses, :integer
  attr :phase, :atom 
  attr :num_players, :integer

  def header(assigns) do
    ~H"""
    <header class= "flex items-center justify-between" >
      <h2 class="text-4xl font-bebasneue font-bold m-5"> Lost in Words </h2>
      <div>
        <NextRound.render state={@phase} num_players={@num_players}/>
        <div> 
          Wins: <%= @wins %> Losses: <%= @losses %>
        </div>
        <div> 
          <%= @name %> 
        </div>
      </div>
    </header> 
    """
  end
end
