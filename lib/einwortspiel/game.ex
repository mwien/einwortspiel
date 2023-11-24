defmodule Einwortspiel.Game do
  alias Einwortspiel.Game.TableSupervisor

  # Client-facing API for the game
  def open_table() do
    TableSupervisor.open_table()
  end

  def join(table_id, player_id) do
    GenServer.call(service_name(table_id), {:join, player_id})
  end

  # TODO: maybe add pause or something
  def manage_round(table_id, command, player_id) do
    GenServer.call(service_name(table_id), {:manage_round, command, player_id})
  end

  def set_attribute(table_id, player_id, attribute, value) do
    GenServer.call(service_name(table_id), {:set_attribute, player_id, attribute, value})
  end

  def move(table_id, player_id, move) do
    GenServer.call(service_name(table_id), {:move, player_id, move})
  end

  def service_name(table_id) do
    GenServer.whereis(Einwortspiel.Application.via_tuple(table_id))
  end
end
