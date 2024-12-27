defmodule EinwortspielWeb.GameLive do
  use EinwortspielWeb, :live_view
  alias EinwortspielWeb.GameLive.{Greet, Ingame}
  alias Einwortspiel.Game.View

  def render(assigns) do
    ~H"""
    <Greet.render :if={!@has_joined} />
    <Ingame.render :if={@has_joined} player_id={@player_id} general={@general} players={@players} />
    """
  end

  def handle_event("join", %{"text" => name}, socket) do
    Einwortspiel.Game.join(
      socket.assigns.room_id,
      socket.assigns.player_id,
      name
    )

    {:noreply, socket}
  end

  def handle_event("start_round", _value, socket) do
    Einwortspiel.Game.start_round(
      socket.assigns.room_id,
      socket.assigns.player_id
    )

    {:noreply, socket}
  end

  def handle_event("submit_clue", %{"text" => clue}, socket) do
    Einwortspiel.Game.submit_clue(
      socket.assigns.room_id,
      socket.assigns.player_id,
      clue
    )

    {:noreply, socket}
  end

  def handle_event("submit_guess", %{"value" => guess}, socket) do
    Einwortspiel.Game.submit_guess(
      socket.assigns.room_id,
      socket.assigns.player_id,
      guess
    )

    {:noreply, socket}
  end

  def handle_info({:game_update, %View{general: general, players: players}}, socket) do
    {:noreply,
     socket
     |> assign(:general, Map.merge(socket.assigns.general, general))
     |> assign(:players, merge_players(socket.assigns.players, players))
     |> assign(
       :has_joined,
       socket.assigns.has_joined or Map.has_key?(players, socket.assigns.player_id)
     )}
  end

  def mount(%{"room_id" => room_id}, %{"user_id" => player_id}, socket) do
    case Einwortspiel.Game.get_game_view(room_id) do
      {:error, :invalid_room_id} ->
        {:ok, redirect(socket, to: ~p"/")}

      {:ok, %Einwortspiel.Game.View{general: general, players: players}} ->
        Phoenix.PubSub.subscribe(Einwortspiel.PubSub, "room:#{room_id}")

        {:ok,
         socket
         |> assign(:room_id, room_id)
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
end
