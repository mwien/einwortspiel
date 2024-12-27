defmodule Einwortspiel.Rooms.Presence do
  use Phoenix.Presence,
    otp_app: :einwortspiel,
    pubsub_server: Einwortspiel.PubSub
end
