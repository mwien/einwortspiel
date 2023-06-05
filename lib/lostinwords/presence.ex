defmodule Lostinwords.Presence do
  use Phoenix.Presence,
    otp_app: :lostinwords,
    pubsub_server: Lostinwords.PubSub
end
