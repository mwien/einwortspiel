defmodule Einwortspiel.GameSupervisor do
  use DynamicSupervisor
  alias Einwortspiel.Game

  def start_link(_opts) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def open_game(options) do
    game = Game.init_game(options)
    DynamicSupervisor.start_child(__MODULE__, {Einwortspiel.GameServer, game})
    game.game_id
  end

  # def abandon_table(_table_id) do
  # TODO
  # end
end
