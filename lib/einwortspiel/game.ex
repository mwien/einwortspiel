defmodule Einwortspiel.Game do
  alias Einwortspiel.Game.{Table, TableSupervisor}

  # Client-facing API for the game
  def open_table(options) do
    TableSupervisor.open_table(options)
  end

  def get_table(table_id) do
    case service_name(table_id) do
      nil -> {:error, :redirect}
      pid -> GenServer.call(pid, {:get_table})
    end
  end

  def has_joined?(table, player_id) do
    Map.has_key?(table.players, player_id)
  end

  # TODO: also check that table_id exists as service name and handle error?
  def join(table_id, player_id) do
    service_name(table_id)
    |> GenServer.call({:join, player_id})
  end

  # check whether new round can be started
  def can_start_round?(table) do
    Table.can_start_round?(table)
  end

  # possible commands: 
  # :start -> for starting the (next) round
  def manage_round(table_id, command, player_id) do
    service_name(table_id)
    |> GenServer.call({:manage_round, command, player_id})
  end

  # possible attributes: 
  # :name -> name of player
  def set_attribute(table_id, player_id, attribute, value) do
    service_name(table_id)
    |> GenServer.call({:set_attribute, player_id, attribute, value})
  end

  # possible moves: 
  # {:submit_clue, clue} 
  # {:submit_guess, guess}
  def move(table_id, player_id, move) do
    service_name(table_id)
    |> GenServer.call({:move, player_id, move})
  end

  defp service_name(table_id) do
    GenServer.whereis(Einwortspiel.Application.via_tuple(table_id))
  end
end
