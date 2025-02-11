defmodule Einwortspiel.Game.State do
  alias __MODULE__
  alias Einwortspiel.Game.{Chat, Info, Player, Round, Settings, Stats}

  # - have option for player to leave as well (set to inactive) in game.ex

  defstruct [
    :room_id,
    :chat,
    :stats,
    :players,
    :round,
    :settings,
    :update
  ]

  def init(room_id, options) do
    %State{
      room_id: room_id,
      chat: Chat.init(),
      stats: Stats.init(),
      players: %{},
      round: nil,
      settings: Settings.init(options),
      update: %Info{general: %{}, players: %{}}
    }
  end

  def add_player(state, player_id, name) do
    if has_player?(state, player_id) do
      {:error, :player_id_exists}
    else
      {:ok,
       %State{state | players: Map.put(state.players, player_id, Player.create(name))}
       |> Info.update_new_player(player_id)
       |> Info.update_general(state)
       |> emit_update()}
    end
  end

  def update_connected_players(state, player_updates) do
    Enum.filter(player_updates, fn {player_id, _} -> Map.has_key?(state.players, player_id) end)
    |> Enum.reduce(state, fn {player_id, val}, state ->
      update_in(state.players[player_id], &Player.set_connected(&1, val))
      |> Info.update_player(state, player_id)
    end)
    |> emit_update()
  end

  def start_round(state, _player_id) do
    case can_start_round(state) do
      :ok ->
        new_state = %State{state | round: Round.init(Map.keys(state.players), state.settings)}
        {:ok, {Info.get_info(new_state), new_state}}

      {:error, error} ->
        {:error, error}
    end
  end

  def process_clue(state, player_id, clue) do
    case Round.make_move(state.round, player_id, {:submit_clue, clue}) do
      {:ok, new_round} ->
        {:ok,
         %State{state | round: new_round}
         |> Info.update_player(state, player_id)
         |> Info.update_general(state)
         |> emit_update()}

      {:error, error} ->
        {:error, error}
    end
  end

  def process_guess(state, player_id, guess) do
    case Round.make_move(state.round, player_id, {:submit_guess, guess}) do
      {:ok, new_round} ->
        {:ok,
         %State{
           state
           | round: new_round,
             stats: Stats.evaluate_result(state.stats, Round.get_phase(new_round))
         }
         |> Info.update_player(state, player_id)
         |> Info.update_general(state)
         |> emit_update()}

      {:error, error} ->
        {:error, error}
    end
  end

  def process_chat_message(state, player_id, message) do
    %State{
      state
      | chat: Chat.add_message(state.chat, player_id, message)
    }
    |> Info.update_chat()
    |> emit_update()
  end

  # TODO: take only active players into account
  def can_start_round(state) do
    cond do
      map_size(state.players) < 2 -> {:error, :too_few_players}
      state.round == nil -> :ok
      Enum.member?([:clues, :guesses], Round.get_phase(state.round)) -> {:error, :ongoing_round}
      true -> :ok
    end
  end

  defp has_player?(state, player_id) do
    Map.has_key?(state.players, player_id)
  end

  defp emit_update(state) do
    {state.update, %State{state | update: %Info{general: %{}, players: %{}, chat: []}}}
  end
end
