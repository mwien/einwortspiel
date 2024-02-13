defmodule Einwortspiel.Game.Info do
  alias __MODULE__

  defstruct [
    :wins,
    :losses
  ]

  def init() do
    %Info{
      wins: 0,
      losses: 0
    }
  end

  def get_wins(info), do: info.wins 
  def get_losses(info), do: info.losses

  def evaluate_result(info, result) do
    case result do
      :win -> %Info{info | wins: info.wins + 1}
      :loss -> %Info{info | losses: info.losses + 1}
      _ -> info
    end 
  end
end
