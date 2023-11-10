defmodule Lostinwords.Game.TableState do
  alias __MODULE__

  # could do more like best guesser
  defstruct [
    :phase,
    :wins,
    :losses
  ]

  def create_state() do
    %TableState{
      phase: :init,
      wins: 0,
      losses: 0
    }
  end

  # is there easier way to update struct?
  def update_phase(state, new_phase) do
    Map.put(state, :phase, new_phase)
  end

  def update_stats(state, win) do
    case win do
      true -> Map.put(state, :wins, state.wins + 1)
      _ -> Map.put(state, :losses, state.losses + 1)
    end
  end
end