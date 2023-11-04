defmodule LostinwordsWeb.GameLive do
  use LostinwordsWeb, :live_view

  alias LostinwordsWeb.GameLive.Header
  alias LostinwordsWeb.GameLive.Main

  # have list of assigns
  # just like struct in module

  # TODO: guessed by
  # TODO: highlighted
  def render(assigns) do
    ~H"""
    <Header.header name={@table.players[@player_id].name} wins = {@table.state.wins} losses = {@table.state.losses} phase={@table.state.phase} num_players={length(Map.keys(@table.players))} />
    <Main.main round={@table.round} state={@table.state} player_id={@player_id} players = {@table.players} />
    """
  end

  #  def render(assigns) do
  #    ~H"""
  #    <div id="game" class="grid grid-cols-1 justify-items-center">
  #      <Words.cards
  #        id="words"
  #        items={@words}
  #        guessed_by={guessers_per_word(@guesses, @animals)}
  #        clickable={
  #          @roles[@player_id] ==
  #            "guesser" and @phase == "guesses"
  #        }
  #        highlighted={@lostwords}
  #      />
  #      <Clues.render
  #        phase={@phase}
  #        roles={@roles}
  #        names={@names}
  #        clues={@clues}
  #        player_id={@player_id}
  #        received_clues_from={@received_clues_from}
  #      />
  #      <Standings.render player_id={@player_id} names={@names} animals={@animals} scores={@scores} active_players={@active_players} />
  #      <NextRound.render phase={@phase} num_players={length(Map.keys(@names))} continue={@continue} />
  #    </div>
  #    """
  #  end
  # TODO: add continue button (on server side check whether move is valid)

  #  # TODO: this is brittle when one person does multiple guesses
  #  def guessers_per_word(guesses, names) do
  #    Enum.reduce(guesses, %{}, fn {id, [word]}, acc ->
  #      Map.update(
  #        acc,
  #        word,
  #        [names[id]],
  #        &([names[id] | &1])
  #      )
  #    end)
  #  end

  def handle_event("start_round", _value, socket) do
    Lostinwords.Game.manage_round(socket.assigns.table_id, :start, socket.assigns.player_id)
    {:noreply, socket}
  end

  def handle_event("submit_clue", %{"value" => %{"text" => clue}}, socket) do
    Lostinwords.Game.move(socket.assigns.table_id, socket.assigns.player_id, {:submit_clue, clue})
    {:noreply, socket}
  end

  def handle_event("submit_guess", %{"value" => guess}, socket) do
    Lostinwords.Game.move(
      socket.assigns.table_id,
      socket.assigns.player_id,
      {:submit_guess, guess}
    )

    {:noreply, socket}
  end

  def handle_event("set_name", %{"value" => %{"text" => name}}, socket) do
    Lostinwords.Game.set_attribute(socket.assigns.table_id, socket.assigns.player_id, :name, name)
    {:noreply, socket}
  end

  def handle_info({:update, table}, socket) do
    IO.inspect(table)
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
       Lostinwords.Game.Table.update_active_players(socket.assigns.table, joins, leaves)
     )}
  end

  def mount(%{"table_id" => table_id}, %{"user_id" => player_id}, socket) do
    Phoenix.PubSub.subscribe(Lostinwords.PubSub, "table:#{table_id}")
    Phoenix.PubSub.subscribe(Lostinwords.PubSub, "player:#{player_id}")
    table = Lostinwords.Game.join(table_id, player_id)

    topic = "table_pres:#{table_id}"

    Phoenix.PubSub.subscribe(Lostinwords.PubSub, topic)

    Lostinwords.Presence.track(
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
