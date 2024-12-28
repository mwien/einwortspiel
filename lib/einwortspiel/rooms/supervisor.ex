defmodule Einwortspiel.Rooms.Supervisor do
  use Supervisor

  def child_spec(init_args) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, init_args},
      restart: :transient
    }
  end

  def start_link(room_id, options) do
    Supervisor.start_link(__MODULE__, [room_id, options])
  end

  @impl true
  def init([room_id, options]) do
    children = [
      {Einwortspiel.Game, [room_id, options]}
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
