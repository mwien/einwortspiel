defmodule Einwortspiel.Game.State do
  alias __MODULE__
  alias Einwortspiel.Game.{Info, Player, Round, Settings, View}

  defstruct [
    :room_id,
    :info,
    :players,
    :round,
    :settings,
    :update
  ]

  def init(room_id, options) do
    %State{
      room_id: room_id,
      info: Info.init(),
      players: %{},
      round: nil,
      settings: Settings.init(options),
      update: %View{general: %{}, players: %{}}
    }
  end

  def add_player(state, player_id, name) do
    if has_player?(state, player_id) do
      {:error, :player_id_exists}
    else
      {:ok,
       %State{state | players: Map.put(state.players, player_id, Player.create(name))}
       |> View.update_new_player(player_id)
       |> View.update_general(state)
       |> emit_update()}
    end
  end

  def start_round(state, _player_id) do
    case can_start_round(state) do
      :ok ->
        new_state = %State{state | round: Round.init(Map.keys(state.players), state.settings)}
        {:ok, {View.get_view(new_state), new_state}}

      {:error, error} ->
        {:error, error}
    end
  end

  def process_clue(state, player_id, clue) do
    case Round.make_move(state.round, player_id, {:submit_clue, clue}) do
      {:ok, new_round} ->
        {:ok,
         %State{state | round: new_round}
         |> View.update_player(state, player_id)
         |> View.update_general(state)
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
             info: Info.evaluate_result(state.info, Round.get_phase(new_round))
         }
         |> View.update_player(state, player_id)
         |> View.update_general(state)
         |> emit_update()}

      {:error, error} ->
        {:error, error}
    end
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
    {state.update, %State{state | update: %View{general: %{}, players: %{}}}}
  end
end
