defmodule EinwortspielWeb.GameLive.Ingame do
  use EinwortspielWeb, :html

  alias EinwortspielWeb.GameLive.PlayerComponent

  # TODO: later separate spectators from players -> spectators below 

  #TODO header -> start_round

  attr :player_id, :string 
  attr :general, :map 
  attr :players, :map 

  def render(assigns) do
    ~H"""
    <.header>
      <div class="flex items-center">
        <.button :if={@general.can_start_round} phx-click="start_round" class="px-1 py-0.5 m-1">
          Next
        </.button>
        <div class="flex items-center mx-1">
          <div class="px-1 py-0.5 bg-green-300 rounded-sm ring ring-violet-700 m-1">
            <%= @general.wins %>
          </div>
          <div class="px-1 py-0.5 bg-red-400 rounded-sm ring ring-violet-700 m-1">
            <%= @general.losses %>
          </div>
        </div>
      </div>
    </.header>
    <.main> 
      <.live_component module={PlayerComponent} id={@player_id} player={@players[@player_id]} this_player={true} phase={@general.phase} />
      <.live_component module={PlayerComponent} id={player_id} player={player} this_player={false} phase={@general.phase} :for={{player_id, player} <- @players} :if={player_id != @player_id} />
    </.main>
    """
  end
end
