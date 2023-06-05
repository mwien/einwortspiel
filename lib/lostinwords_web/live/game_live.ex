defmodule LostinwordsWeb.GameLive do
  use LostinwordsWeb, :live_view

  alias LostinwordsWeb.GameLive.Words
  alias LostinwordsWeb.GameLive.Clues
  alias LostinwordsWeb.GameLive.Standings
  alias LostinwordsWeb.GameLive.NextRound
  alias Lostinwords.Presence

# have list of assigns
# just like struct in module

  def render(assigns) do
    ~H"""
    <div id="game" class="grid grid-cols-1 justify-items-center">
      <Words.cards
        id="words"
        items={@words}
        guessed_by={guessers_per_word(@guesses, @animals)}
        clickable={
          @roles[@player_id] ==
            "guesser" and @phase == "guesses"
        }
        highlighted={@lostwords}
      />
      <Clues.render
        phase={@phase}
        roles={@roles}
        names={@names}
        clues={@clues}
        player_id={@player_id}
        received_clues_from={@received_clues_from}
      />
      <Standings.render player_id={@player_id} names={@names} animals={@animals} scores={@scores} active_players={@active_players} />
      <NextRound.render phase={@phase} num_players={length(Map.keys(@names))} continue={@continue} />
    </div>
    """
  end
  # TODO: add continue button (on server side check whether move is valid)

  # TODO: this is brittle when one person does multiple guesses
  def guessers_per_word(guesses, names) do
    Enum.reduce(guesses, %{}, fn {id, [word]}, acc ->
      Map.update(
        acc,
        word,
        [names[id]],
        &([names[id] | &1])
      )
    end)
  end

  def handle_event("start_round", _value, socket) do
    Lostinwords.Game.start_round(socket.assigns.table_id)
    {:noreply, socket}
  end

  def handle_event("submit_clue", %{"value" => %{"text" => clue}}, socket) do
    Lostinwords.Game.move(socket.assigns.table_id, socket.assigns.player_id, {:submit_clue, clue})
    # if :ok
    {:noreply,
     socket
     |> assign(:clues, Map.put(socket.assigns.clues, socket.assigns.player_id, clue))}
  end

  def handle_event("submit_guess", %{"value" => guess}, socket) do
    Lostinwords.Game.move(socket.assigns.table_id, socket.assigns.player_id, {:submit_guess, guess})
    {:noreply, socket}
  end

  def handle_event("set_name", %{"value" => %{"text" => name}}, socket) do
    Lostinwords.Game.set_name(socket.assigns.table_id, socket.assigns.player_id, name)
    {:noreply, socket}
  end

  def handle_event("force_continue", _value, socket) do
    Lostinwords.Game.force_continue(socket.assigns.table_id)
    {:noreply, socket}
  end

# maybe add a set animal

  def handle_info({:info_roles, roles}, socket) do
    {:noreply, assign(socket, :roles, roles)}
  end

  # TODO: just always get the words from the server!!!
  # do this much much nicer TODO
  def handle_info({:info_words, words}, socket) do
    {:noreply, assign(socket, :words, 
  # don't have explicit number 4
    if length(words) < 4 do
      words ++ [" "]   
    else 
      words
    end
    )}
  end

  def handle_info({:info_unauthorized_move}, socket) do
    {:noreply, put_flash(socket, :error, "Unauthorized Move")}
  end

  def handle_info({:info_received_clue, player_id}, socket) do
    {:noreply,
     assign(socket, :received_clues_from, [player_id | socket.assigns.received_clues_from])}
  end

  def handle_info({:info_clues, clues}, socket) do
    {:noreply, assign(socket, :clues, clues)}
  end

  def handle_info({:info_received_guess, player_id, _verdict}, socket) do
    {:noreply,
     assign(socket, :received_guesses_from, [player_id | socket.assigns.received_guesses_from])}
  end

  # just get the new words and the revealed lostword from server!!!
  def handle_info({:info_lostwords, lostwords}, socket) do
    # make nicer
    if socket.assigns.roles[socket.assigns.player_id] == "cluer" do
      {:noreply, 
        assign(socket, :lostwords, lostwords)
      |> assign(:words, List.delete(socket.assigns.words ++ lostwords, " "))}
    else
      {:noreply, 
        assign(socket, :lostwords, lostwords)
      }
    end
  end

  def handle_info({:info_finished, player_id}, socket) do
    {:noreply, assign(socket, :finished, [player_id | socket.assigns.finished])}
  end

  def handle_info({:info_score, player_id, _plus_score, new_score}, socket) do
    # sorted_scores = Enum.sort(@scores, &(elem(&1,1) <= elem(&2,1))) 
    {:noreply, assign(socket, :scores, Map.put(socket.assigns.scores, player_id, new_score))}
  end

  def handle_info({:info_guesses, guesses}, socket) do
    {:noreply, assign(socket, :guesses, guesses)}
  end

  def handle_info({:info_name_set, player_id, name}, socket) do
    {:noreply, assign(socket, :names, Map.put(socket.assigns.names, player_id, name))
      |> assign(:animals, Map.put(socket.assigns.animals, player_id, "dove.svg"))
    }
  end

  def handle_info({:info_animal_set, player_id, animal}, socket) do
    {:noreply, assign(socket, :animals, Map.put(socket.assigns.animals, player_id, animal))}
  end

  # TODO: maybe do this differently -> YES!!!
  # server changes names/scores => info to client
  # without explicit join info
  # do this together with initial name being set automatically
  def handle_info({:info_player_joined, player_id}, socket) do
    {:noreply,
     assign(socket, :names, Map.put(socket.assigns.names, player_id, ""))
     |> assign(:scores, Map.put(socket.assigns.scores, player_id, 0))}
  end

  # maybe write reinit client state function
  # put logic out of here!
  def handle_info({:info_new_phase, phase}, socket) do
    {:noreply,
     if phase == "clues" do
       assign(socket, :received_clues_from, [])
       |> assign(:received_guesses_from, [])
       |> assign(:clues, %{})
       |> assign(:guesses, %{})
       |> assign(:lostwords, [])
     else
       socket
     end
     |> assign(:continue, false)
     |> assign(:phase, phase)}
  end

  # i think dis okay
  # also table_id pubsub is a good idea!
  # write function in pubsub mod for handling active players
  def handle_info(%{event: "presence_diff", payload: %{joins: joins, leaves: leaves}}, socket) do
    afterjoin = Enum.reduce(Map.keys(joins), socket.assigns.active_players, &([&1 | &2]))
    afterleave = Enum.reduce(Map.keys(leaves), afterjoin, &Enum.filter(&2, fn x -> x != &1 end))
    {:noreply, assign(socket, :active_players, afterleave)}
  end

  def handle_info({:info_continue, flag}, socket) do
    {:noreply, assign(socket, :continue, flag)}
  end

  def mount(%{"table_id" => table_id}, %{"user_id" => player_id}, socket) do
    Phoenix.PubSub.subscribe(Lostinwords.PubSub, "user:" <> player_id)
    init_info = Lostinwords.Game.join(table_id, player_id)

    topic = "table:#{table_id}"

    Phoenix.PubSub.subscribe(Lostinwords.PubSub, topic)

    Presence.track(
      self(),
      topic,
      player_id,
      %{}
    )

    {:ok,
     socket
     |> assign(:table_id, table_id)
     |> assign(:player_id, player_id)
     |> assign(init_info)}
  end
end
