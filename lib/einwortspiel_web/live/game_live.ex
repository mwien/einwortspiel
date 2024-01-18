defmodule EinwortspielWeb.GameLive do
  use EinwortspielWeb, :live_view

  alias EinwortspielWeb.GameLive.{Greet, Pregame, Ingame}

  # TUDU: have functions in app for player in table players etc (prob. in table module)
  def render(assigns) do
    ~H"""
    <Greet.render :if={!Map.has_key?(@table.players, @player_id)} />
    <Pregame.render
      :if={Map.has_key?(@table.players, @player_id) and @table.state.phase == :init}
      player_id={@player_id}
      players={@table.players}
      state={@table.state}
    />
    <Ingame.render
      :if={Map.has_key?(@table.players, @player_id) and @table.state.phase != :init}
      round={@table.round}
      player_id={@player_id}
      players={@table.players}
      state={@table.state}
    />
    """
  end

  def handle_event(
        "join",
        _value,
        %{assigns: %{table_id: table_id, player_id: player_id}} = socket
      ) do
    topic = "table_pres:#{table_id}"
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
      :name,
      name
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
      {:error, :redirect} ->
        {:ok, redirect(socket, to: ~p"/")}

      table ->
        Phoenix.PubSub.subscribe(Einwortspiel.PubSub, "table:#{table_id}")

        {:ok,
         socket
         |> assign(:table_id, table_id)
         |> assign(:player_id, player_id)
         |> assign(:table, table)}
    end
  end
end
