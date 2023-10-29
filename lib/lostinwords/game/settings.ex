defmodule Lostinwords.Game.Settings do
  alias __MODULE__
 
  # currently only nr_cluers = 1 and nr_lostwords = 1 is fully supported
  defstruct [
    nr_leftwords: 3,
    nr_lostwords: 1,
    nr_cluers: 1
  ]

  def default_settings() do
    %Settings{} 
  end
end
