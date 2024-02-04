defmodule Einwortspiel.GameState do
  alias __MODULE__
  alias Einwortspiel.Players

  defstruct [
    :phase,
    :waiting_for,
    :playing,
    :spectating,
    :wins,
    :losses
  ]

  def init() do
    %GameState{
      phase: :init,
      waiting_for: MapSet.new(),
      playing: MapSet.new(),
      spectating: MapSet.new(),
      # TODO: replace by Stat module
      wins: 0,
      losses: 0
    }
  end

  def check(state, :start_round, _player_id, players) do
    case can_start_round(state) do
      :ok ->
        {:ok,
         %GameState{
           state
           | phase: :clues,
             waiting_for: Players.get_active(players),
             playing: Players.get_active(players),
             spectating: Players.get_inactive(players)
         }}

      {:error, error} ->
        {:error, error}
    end
  end

  def check(state, :add_player, player_id, players) do
    if !Players.has_player?(players, player_id) do
      {:ok, %GameState{state | spectating: MapSet.put(state.spectating, player_id)}}
    else
      {:error, :player_exists}
    end
  end

  def check(state, :submit_clue, player_id, players) do
    cond do
      state.phase != :clues ->
        {:error, :incorrect_phase}

      !Enum.member?(state.waiting_for, player_id) ->
        {:error, :already_submitted}

      true ->
        {:ok,
         %GameState{state | waiting_for: MapSet.delete(state.waiting_for, player_id)}
         |> update_phase(players)}
    end
  end

  def check(state, :submit_guess, player_id, players) do
    cond do
      state.phase != :guesses ->
        {:error, :incorrect_phase}

      !Enum.member?(state.waiting_for, player_id) ->
        {:error, :already_submitted}

      true ->
        {:ok,
         %GameState{state | waiting_for: MapSet.delete(state.waiting_for, player_id)}
         |> update_phase(players)}
    end
  end

  def can_start_round(state) do
    cond do
      MapSet.size(state.active) < 2 -> {:error, :too_few_players}
      Enum.member?([:clues, :guesses], state.phase) -> {:error, :ongoing_round}
      true -> :ok
    end
  end

  defp update_phase(state, players) do
    if Enum.empty?(state.waiting_for) do
      case state.phase do
        :clues -> %GameState{state | phase: :guesses, waiting_for: state.playing}
        :guesses -> evaluate_round(state, players)
        _ -> state
      end 
    else
      state
    end
  end

  defp evaluate_round(state, players) do
    if Enum.all?(state.playing, &Players.correct_guess?(players, &1)) do
      %GameState{state | phase: :win,  wins: state.wins + 1}
    else 
      %GameState{state | phase: :loss, losses: state.losses + 1}
    end
  end

end
