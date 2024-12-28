defmodule Einwortspiel.Game.Stats do
  alias __MODULE__

  defstruct [
    :wins,
    :losses
  ]

  def init() do
    %Stats{
      wins: 0,
      losses: 0
    }
  end

  def get_wins(stats), do: stats.wins
  def get_losses(stats), do: stats.losses

  def evaluate_result(stats, result) do
    case result do
      :win -> %Stats{stats | wins: stats.wins + 1}
      :loss -> %Stats{stats | losses: stats.losses + 1}
      _ -> stats
    end
  end
end
