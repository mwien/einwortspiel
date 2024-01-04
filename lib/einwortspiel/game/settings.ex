defmodule Einwortspiel.Game.Settings do
  alias __MODULE__
 
  defstruct [
    nr_commonwords: 2,
    language: "de"
  ]

  def default_settings() do
    %Settings{} 
  end
end
