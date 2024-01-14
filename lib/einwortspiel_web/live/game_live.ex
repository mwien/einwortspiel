defmodule EinwortspielWeb.GameLive do
  use EinwortspielWeb, :live_view

  alias EinwortspielWeb.GameLive.Header
  alias EinwortspielWeb.GameLive.Main

  def render(assigns) do
    ~H"""
    <div class="flex flex-col justify-between items-center h-dvh">
      <Header.ingame
        player_id={@player_id}
        players={@table.players}
        state={@table.state}
      />
      <Main.render
        player_id={@player_id} 
        players={@table.players} 
        round={@table.round} 
        state={@table.state} 
      />
      <footer class="m-1 text-sm">
        <dl class="grid grid-flow-col auto-cols-max justify-center" >
          <dt class="col-start-1 justify-self-end" >
            <div class="w-3.5 h-3.5 mt-1">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-mail"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path><polyline points="22,6 12,13 2,6"></polyline></svg>
            </div> 
          </dt>
          <dd class="col-start-2 justify-self-start ml-1.5"> marcel.wienoebst (AT) gmx.de </dd>
          <dt class="col-start-1 justify-self-end text-md">
            &copy;
          </dt> 
          <dd class="col-start-2 justify-self-start ml-1.5"> <%= Map.fetch!(DateTime.utc_now, :year)  %> Marcel Wienöbst. All rights reserved. </dd>
        </dl>
      </footer>
    </div>
    """
  end
  
  def handle_event("join", _value, %{assigns: %{table_id: table_id, player_id: player_id}} = socket) do
    topic = "table_pres:#{table_id}"
    Phoenix.PubSub.subscribe(Einwortspiel.PubSub, "table:#{table_id}")
    # TUDU: do we use this currently?
    Phoenix.PubSub.subscribe(Einwortspiel.PubSub, "player:#{player_id}")
    Phoenix.PubSub.subscribe(Einwortspiel.PubSub, topic)
    Einwortspiel.Presence.track(
      self(),
      topic,
      player_id,
      %{}
    )
    Einwortspiel.Game.join(table_id, player_id)
    {:noreply, socket}
  end
  
  # TUDU -> "text" vs "value" (form vs button) -> unify?
  def handle_event("set_name", %{"text" => name}, socket) do
    Einwortspiel.Game.set_attribute(
      socket.assigns.table_id, 
      socket.assigns.player_id, 
      :name, name
    )
    {:noreply, socket}
  end

  def handle_event("start_round", _value, socket) do
    Einwortspiel.Game.manage_round(
      socket.assigns.table_id, 
      :start, 
      socket.assigns.player_id
    )
    {:noreply, socket}
  end

  def handle_event("submit_clue", %{"text" => clue}, socket) do
    Einwortspiel.Game.move(
      socket.assigns.table_id, 
      socket.assigns.player_id, 
      {:submit_clue, clue}
    )
    {:noreply, socket}
  end

  def handle_event("submit_guess", %{"value" => guess}, socket) do
    Einwortspiel.Game.move(
      socket.assigns.table_id,
      socket.assigns.player_id,
      {:submit_guess, guess}
    )
    {:noreply, socket}
  end

  # TUDU: make this more fine_grained at some point -> round, state, players, chat, ...
  def handle_info({:update, table}, socket) do
    {:noreply, assign(socket, :table, table)}
  end

  def handle_info({:error, error}, socket) do
    {:noreply, put_flash(socket, :error, error)}
  end

  def handle_info(%{event: "presence_diff", payload: %{joins: joins, leaves: leaves}}, socket) do
    {:noreply,
     assign(
       socket,
       :table,
       Einwortspiel.Game.Table.update_connected_players(socket.assigns.table, joins, leaves)
     )}
  end

  def mount(%{"table_id" => table_id}, %{"user_id" => player_id}, socket) do
    case Einwortspiel.Game.get_table(table_id) do
      {:error, :redirect} -> {:ok, redirect(socket, to: ~p"/")}
      table -> {:ok, 
        socket 
        |> assign(:table_id, table_id)
        |> assign(:player_id, player_id)
        |> assign(:table, table)
      }
    end
  end
end
