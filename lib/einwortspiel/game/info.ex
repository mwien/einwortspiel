defmodule Einwortspiel.Game.Info do
  alias __MODULE__ 

  defstruct [
    :phase, 
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
end
