defmodule Einwortspiel.Game.Round do
  alias __MODULE__

  # TODO: words etc in another nested struct???

  defstruct [
    :number, # or number
    :words, 
    :clues, 
    :guesses,
    :phase
  ]

  def init() do
    %Round{
      number: 0,
      words: nil,
      clues: nil, 
      guesses: nil, 
      phase: :init
    }
  end
end
