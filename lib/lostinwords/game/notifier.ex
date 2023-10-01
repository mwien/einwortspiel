defmodule Lostinwords.Game.Notifier do
  alias Phoenix.PubSub

  # TODO: better names 

  def publish_table(table_id, payload) do
    PubSub.broadcast(Lostinwords.PubSub, "table:" <> table_id, payload) 
  end

  def publish_player(player_id, payload) do
    #IO.inspect({table_id, player_id, instruction_payload})
    PubSub.broadcast(Lostinwords.PubSub, "player:" <> player_id, payload)
  end
end
