defmodule EinwortspielWeb.GameLive do
  use EinwortspielWeb, :live_view

  alias EinwortspielWeb.GameLive.{Greet, Pregame, Ingame}

  attr :player_id, :string
  attr :has_joined, :boolean
  attr :table_phase, :atom
  attr :can_start_round, :boolean
  attr :wins, :integer
  attr :losses, :integer
  attr :players, :map
  attr :clues, :map, default: nil
  attr :guesses, :map, default: nil
  attr :allwords, :map, default: nil
  attr :extrawords, :map, default: nil
  attr :waiting_for, :map, default: nil
  attr :round_phase, :atom, default: nil

  def render(assigns) do
    ~H"""
    <Greet.render :if={!@has_joined} />
    <Pregame.render
      :if={@has_joined and @table_phase == :init}
      can_start_round={@can_start_round}
      player_id={@player_id}
      players={@players}
    />
    <Ingame.render
      :if={@has_joined and @table_phase != :init}
      player_id={@player_id}
      clues={@clues}
      guesses={@guesses}
      allwords={@allwords}
      extrawords={@extrawords}
      waiting_for={@waiting_for}
      table_phase={@table_phase}
      round_phase={@round_phase}
      players={@players}
      can_start_round={@can_start_round}
      wins={@wins}
      losses={@losses}
    />
    """
  end

  def handle_event(
        "join",
        _value,
        %{assigns: %{table_id: table_id, player_id: player_id}} = socket
      ) do
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

  # TUDU: make updates more fine_grained at some point
  def handle_info({:update, table}, socket) do
    {:noreply, process_table(socket, table, socket.assigns.player_id)}
  end

  def handle_info({:error, error}, socket) do
    {:noreply, put_flash(socket, :error, error)}
  end

  # TODO: fix presence stuff
  # def handle_info(%{event: "presence_diff", payload: %{joins: joins, leaves: leaves}}, socket) do
  #  {:noreply,
  #   assign(
  #     socket,
  #     :table,
  #     Einwortspiel.Game.Table.update_connected_players(socket.assigns.table, joins, leaves)
  #   )}
  # end

  def mount(%{"table_id" => table_id}, %{"user_id" => player_id}, socket) do
    case Einwortspiel.Game.get_table(table_id) do
      {:error, :redirect} ->
        {:ok, redirect(socket, to: ~p"/")}

      table ->
        Phoenix.PubSub.subscribe(Einwortspiel.PubSub, "table:#{table_id}")
        # TUDU: do we use this currently?
        Phoenix.PubSub.subscribe(Einwortspiel.PubSub, "player:#{player_id}")
        # topic = "table_pres:#{table_id}"
        # Phoenix.PubSub.subscribe(Einwortspiel.PubSub, topic)

        # Einwortspiel.Presence.track(
        #    self(),
        #    topic,
        #    player_id,
        #  %{}
        # )

        {:ok,
         socket
         |> assign(:table_id, table_id)
         |> assign(:player_id, player_id)
         |> process_table(table, player_id)}
    end
  end

  defp process_table(socket, table, player_id) do
    socket
    |> assign(:has_joined, Einwortspiel.Game.has_joined?(table, player_id))
    |> assign(:players, table.players)
    |> assign(:can_start_round, Einwortspiel.Game.can_start_round?(table))
    |> assign(:table_phase, table.state.phase)
    |> assign(:wins, table.state.wins)
    |> assign(:losses, table.state.losses)
    |> process_round(table.round)
  end

  defp process_round(socket, nil) do
    socket
  end

  defp process_round(socket, round) do
    socket
    |> assign(:clues, round.clues)
    |> assign(:guesses, round.guesses)
    |> assign(:allwords, round.allwords)
    |> assign(:extrawords, round.extrawords)
    |> assign(:waiting_for, round.waiting_for)
    |> assign(:round_phase, round.phase)
  end
end
