defmodule Einwortspiel.Rooms.Notifier do
  alias Phoenix.PubSub

  def notify_room(room_id, payload) do
    PubSub.broadcast(Einwortspiel.PubSub, "room:" <> room_id, payload)
  end
end
