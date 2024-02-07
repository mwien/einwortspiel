defmodule Einwortspiel.Game.Info do
  alias __MODULE__

  defstruct [
    :phase,
    :last_result,
    :wins,
    :losses
  ]

  def init() do
    %Info{
      phase: :init,
      wins: 0,
      losses: 0
    }
  end

  # TODO: catch all case?
  def round_signal(info, signal) do
    case signal do
      :start_of_round -> %Info{info | phase: :in_round}
      {:end_of_round, result} -> %Info{info | phase: :post_round} |> evaluate_result(result)
    end
  end

  def evaluate_result(info, result) do
    case result do
      :win -> %Info{info | wins: info.wins + 1, last_result: :win}
      :loss -> %Info{info | losses: info.losses + 1, last_result: :loss}
    end 
  end
end
