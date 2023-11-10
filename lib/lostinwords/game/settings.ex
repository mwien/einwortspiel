defmodule Lostinwords.Game.Settings do
  alias __MODULE__
 
  defstruct [
    nr_commonwords: 2,
  ]

  def default_settings() do
    %Settings{} 
  end
end
