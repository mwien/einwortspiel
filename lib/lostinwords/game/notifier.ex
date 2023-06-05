defmodule Lostinwords.Game.PlayerNotifier do
  alias Phoenix.PubSub

  def publish(table_id, player_id, instruction_payload) do
    IO.inspect({table_id, player_id, instruction_payload})
    PubSub.broadcast(Lostinwords.PubSub, "user:" <> player_id, instruction_payload)
  end
end
