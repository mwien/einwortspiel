defmodule Einwortspiel.Rooms do
  use DynamicSupervisor

  alias Einwortspiel.Rooms.Notifier

  def start_link(_opts) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def open_room(options) do
    room_id = Einwortspiel.Generator.gen_id()

    DynamicSupervisor.start_child(
      __MODULE__,
      {Einwortspiel.Rooms.Supervisor, [room_id, options]}
    )

    room_id
  end

  # TODO: add close room call
  # and worker which cleans up abandoned rooms?

  def publish_for_room(room_id, message) do
    Notifier.notify_room(room_id, message)
  end

  # def message_room (chat message)

  # TODO: later add this
  # def add_ai_player_to_room(room_id)
  # -> go through room.supervisor
end
