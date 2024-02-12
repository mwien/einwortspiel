defmodule EinwortspielWeb.GameLive do
  use EinwortspielWeb, :live_view

  alias Einwortspiel.Generator
  alias EinwortspielWeb.GameLive.{Greet, Ingame}

  def render(assigns) do
    ~H"""
    <Greet.render :if={!@has_joined} /> 
    <Ingame.render player_id={@player_id} general={@general} players={@players} :if={@has_joined} />
    """
  end

  def handle_event("join", _value, socket) do
    Einwortspiel.GameServer.join(
      socket.assigns.game_id, 
      socket.assigns.player_id, 
      Generator.gen_name()
    )
    {:noreply, socket}
  end

  def handle_event("start_round", _value, socket) do
    Einwortspiel.GameServer.start_round(
      socket.assigns.game_id,
      socket.assigns.player_id
    )
    {:noreply, socket}
  end

  def handle_event("submit_clue", %{"text" => clue}, socket) do
    Einwortspiel.GameServer.submit_clue(
      socket.assigns.game_id,
      socket.assigns.player_id,
      clue
    )

    {:noreply, socket}
  end

  def handle_event("submit_guess", %{"value" => guess}, socket) do
    Einwortspiel.GameServer.submit_guess(
      socket.assigns.game_id,
      socket.assigns.player_id,
      guess
    )

    {:noreply, socket}
  end


  def handle_info({:update, {general, players}}, socket) do
    IO.inspect(general)
    IO.inspect(players)
    {:noreply, socket 
      |> assign(:general, Map.merge(socket.assigns.general, general))
      |> assign(:players, merge_players(socket.assigns.players, players))
      |> assign(:has_joined, socket.assigns.has_joined or Map.has_key?(players, socket.assigns.player_id))
    }
  end

  def mount(%{"game_id" => game_id}, %{"user_id" => player_id}, socket) do
    case Einwortspiel.GameServer.get_game(game_id) do
      {:error, :invalid_game_id} ->
        {:ok, redirect(socket, to: ~p"/")}

      {:ok, {general, players}} ->
        Phoenix.PubSub.subscribe(Einwortspiel.PubSub, "game_info:#{game_id}")
        
        # topic = "game_pres:#{game_id}"
        # Phoenix.PubSub.subscribe(Einwortspiel.PubSub, topic)
        #
        # Einwortspiel.Presence.track(
        #    self(),
        #    topic,
        #    player_id,
        #  %{}
        # )

        {:ok,
         socket
         |> assign(:game_id, game_id)
         |> assign(:player_id, player_id)
         |> assign(:general, general)
         |> assign(:players, players)
         |> assign(:has_joined, Map.has_key?(players, player_id))}
    end
  end

  defp merge_players(old_players, new_players) do
    Enum.reduce(new_players, old_players, fn {player_id, player}, players -> 
      Map.put(players, player_id, Map.merge(Map.get(players, player_id, %{}), player))
    end)
  end

  #  attr :player_id, :string
  #  attr :has_joined, :boolean
  #  attr :table_phase, :atom
  #  attr :ready_to_start, :boolean
  #  attr :wins, :integer
  #  attr :losses, :integer
  #  attr :players, :map
  #  attr :clues, :map, default: nil
  #  attr :guesses, :map, default: nil
  #  attr :allwords, :map, default: nil
  #  attr :extrawords, :map, default: nil
  #  attr :waiting_for, :map, default: nil
  #  attr :round_phase, :atom, default: nil
  #
  #  def render(assigns) do
  #    ~H"""
  #    <Greet.render :if={!@has_joined} />
  #    <Pregame.render
  #      :if={@has_joined and @table_phase == :init}
  #      ready_to_start={@ready_to_start}
  #      player_id={@player_id}
  #      players={@players}
  #    />
  #    <Ingame.render
  #      :if={@has_joined and @table_phase != :init}
  #      player_id={@player_id}
  #      clues={@clues}
  #      guesses={@guesses}
  #      allwords={@allwords}
  #      extrawords={@extrawords}
  #      waiting_for={@waiting_for}
  #      table_phase={@table_phase}
  #      round_phase={@round_phase}
  #      players={@players}
  #      ready_to_start={@ready_to_start}
  #      wins={@wins}
  #      losses={@losses}
  #    />
  #    """
  #  end

  # TUDU -> "text" vs "value" (form vs button) -> unify?
  #  def handle_event("set_name", %{"text" => name}, socket) do
  #    Einwortspiel.Game.update_player(
  #      socket.assigns.table_id,
  #      socket.assigns.player_id,
  #      :name,
  #      name
  #    )
  #
  #    {:noreply, socket}
  #  end
  #

  # TUDU: make updates more fine_grained at some point
  #  def handle_info({:update, table}, socket) do
  #  {:noreply, process_table(socket, table, socket.assigns.player_id)}
  # end

  # def handle_info({:error, error}, socket) do
  #  {:noreply, put_flash(socket, :error, error)}
  # end

  # TODO: fix presence stuff
  # def handle_info(%{event: "presence_diff", payload: %{joins: joins, leaves: leaves}}, socket) do
  #  {:noreply,
  #   assign(
  #     socket,
  #     :table,
  #     Einwortspiel.Game.Table.update_connected_players(socket.assigns.table, joins, leaves)
  #   )}
  # end

  #  defp process_table(socket, table, player_id) do
  #    socket
  #    |> assign(:has_joined, Einwortspiel.Game.has_player?(table, player_id))
  #    |> assign(:players, table.players)
  #    |> assign(
  #      :ready_to_start,
  #      case Einwortspiel.Game.ready_to_start?(table) do
  #        {false, _} -> false
  #        true -> true
  #      end
  #    )
  #    |> assign(:table_phase, table.state.phase)
  #    |> assign(:wins, table.state.wins)
  #    |> assign(:losses, table.state.losses)
  #    |> process_round(table.round)
  #  end
  #
  #  defp process_round(socket, nil) do
  #    socket
  #  end
  #
  #  defp process_round(socket, round) do
  #    socket
  #    |> assign(:clues, round.clues)
  #    |> assign(:guesses, round.guesses)
  #    |> assign(:allwords, round.allwords)
  #    |> assign(:extrawords, round.extrawords)
  #    |> assign(:waiting_for, round.waiting_for)
  #    |> assign(:round_phase, round.phase)
  #  end
end
