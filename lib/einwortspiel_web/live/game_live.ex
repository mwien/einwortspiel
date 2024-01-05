defmodule EinwortspielWeb.GameLive do
  use EinwortspielWeb, :live_view

  alias EinwortspielWeb.GameLive.Header
  alias EinwortspielWeb.GameLive.Main
  alias EinwortspielWeb.GameLive.Spectator

  # have list of assigns
  def render(assigns) do
    ~H"""
    <div class="flex justify-center font-oswald text-lg md:text-xl">
    <div class="w-full md:w-11/12 lg:w-3/4 xl:w-2/3 2xl:w-1/2" > 
    <Header.header name={@table.players[@player_id].name} wins = {@table.state.wins} losses = {@table.state.losses} phase={@table.state.phase} num_players={length(Map.keys(Map.filter(@table.players, fn {_, value} -> !value.spectator end)))} />
    <Main.main round={@table.round} state={@table.state} player_id={@player_id} players = {@table.players} :if={!@table.players[@player_id].spectator}/>
    <Spectator.render :if={@table.players[@player_id].spectator} />
    </div>
    </div>
    """
  end

  def handle_event("start_round", _value, socket) do
    Einwortspiel.Game.manage_round(socket.assigns.table_id, :start, socket.assigns.player_id)
    {:noreply, socket}
  end

  def handle_event("submit_clue", %{"text" => clue}, socket) do
    Einwortspiel.Game.move(socket.assigns.table_id, socket.assigns.player_id, {:submit_clue, clue})
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

  def handle_event("set_name", %{"text" => name}, socket) do
    Einwortspiel.Game.set_attribute(socket.assigns.table_id, socket.assigns.player_id, :name, name)
    {:noreply, socket}
  end

  def handle_event("leave_spectator", _value, socket) do
    Einwortspiel.Game.set_attribute(socket.assigns.table_id, socket.assigns.player_id, :spectator, false)
    {:noreply, socket}
  end

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
       Einwortspiel.Game.Table.update_active_players(socket.assigns.table, joins, leaves)
     )}
  end

  def mount(%{"table_id" => table_id}, %{"user_id" => player_id}, socket) do
    Phoenix.PubSub.subscribe(Einwortspiel.PubSub, "table:#{table_id}")
    Phoenix.PubSub.subscribe(Einwortspiel.PubSub, "player:#{player_id}")

    case Einwortspiel.Game.join(table_id, player_id) do
      # TODO: maybe have proper error page
      {:error, :redirect} -> {:ok, redirect(socket, to: ~p"/")}
      table -> 
        topic = "table_pres:#{table_id}"

        Phoenix.PubSub.subscribe(Einwortspiel.PubSub, topic)

        Einwortspiel.Presence.track(
          self(),
          topic,
          player_id,
          %{}
        )

        {:ok,
         socket
         |> assign(:table_id, table_id)
         |> assign(:player_id, player_id)
         |> assign(:table, table)}
      end
  end
end
