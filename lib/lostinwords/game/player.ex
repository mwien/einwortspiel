defmodule Lostinwords.Players.Player do
  alias __MODULE__
  alias Lostinwords.Generator

  # have secret player_id and open one?

  # put player_id in here? -> prob yes

  # maybe add something like in round
  defstruct [
    :player_id,
    :name,
    :icon,
    :score,
    :active, # as in online
    :spectator, # as in whether just onlooker
  ]

  def new(player_id) do
    %Player{player_id: player_id, name: Generator.gen_name(), icon: Generator.gen_icon(), score: 0, active: true, # should work or race cond?
      spectator: true} # what to do with spectator?
  end 

end
