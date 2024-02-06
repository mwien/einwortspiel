defmodule Einwortspiel.Notifier do
  alias Phoenix.PubSub

  def publish_game_info(game_id, payload) do
    PubSub.broadcast(Einwortspiel.PubSub, "game:" <> game_id, payload)
  end
end
