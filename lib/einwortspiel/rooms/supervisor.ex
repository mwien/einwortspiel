defmodule Einwortspiel.Rooms.Supervisor do
  use Supervisor

  def start_link(room_id) do
    Supervisor.start_link(__MODULE__, :ok, name: Einwortspiel.Application.room_via_tuple(room_id))
  end

  @impl true
  def init(room_id) do
    children = [
      {Einwortspiel.Game, room_id}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end

  # TODO: add ai player 
  #  def start_ai_player(game_room_pid, ai_player_opts) do
  #    spec = %{
  #      id: MyApp.AIPlayer,
  #      start: {MyApp.AIPlayer, :start_link, [ai_player_opts]},
  #      restart: :transient
  #    }
  #
  #    Supervisor.start_child(game_room_pid, spec)
  #  end
  # also have terminate option
end
