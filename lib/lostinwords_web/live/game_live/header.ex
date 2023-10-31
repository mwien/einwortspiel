defmodule LostinwordsWeb.GameLive.Header do
  use Phoenix.Component 

  attr :name, :string
  attr :wins, :integer
  attr :losses, :integer

  def header(assigns) do
    ~H"""
    <header class="flex align-items-center" >
      <h2 class="text-4xl font-bebas-neue font-bold m-5"> Lost in Words </h2>
      <div> 
        Wins: <%= @wins %> Losses: <%= @losses %>
      </div>
      <div> 
        <%= @name %> 
      </div>
    </header> 
    """
  end
end
