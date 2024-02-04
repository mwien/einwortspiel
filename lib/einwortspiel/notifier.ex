defmodule Einwortspiel.Game.Notifier do
  alias Phoenix.PubSub

  # TODO: better names 

  def publish_table(table_id, payload) do
    PubSub.broadcast(Einwortspiel.PubSub, "table:" <> table_id, payload)
  end

  def publish_player(player_id, payload) do
    PubSub.broadcast(Einwortspiel.PubSub, "player:" <> player_id, payload)
  end
end
