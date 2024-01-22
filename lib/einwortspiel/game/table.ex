defmodule Einwortspiel.Game.Table do
  alias __MODULE__
  alias Einwortspiel.Game.Player
  alias Einwortspiel.Game.Round
  alias Einwortspiel.Game.Settings
  alias Einwortspiel.Game.TableState

  defstruct [
    :table_id,
    :round,
    :players,
    :settings,
    :state
  ]

  def create_table(options) do
    %Table{
      table_id: generate_table_id(),
      round: nil,
      players: %{},
      settings: Settings.get_settings(options),
      state: TableState.create_state()
    }
  end

  def create_player(table, player_id) do
    if !Map.has_key?(table.players, player_id) do
      {:ok,
       %Table{table | players: Map.put(table.players, player_id, Player.create_player(player_id))}}
    else
      # should this be error? -> maybe remove this
      {:error, :already_joined}
    end
  end

  def update_player(table, player_id, attribute, value) do
    if Map.has_key?(table.players, player_id) do
      {:ok,
       %Table{
         table
         | players:
             Map.put(
               table.players,
               player_id,
               Player.update_player(table.players[player_id], attribute, value)
             )
       }}
    else
      {:error, :invalid_player_id}
    end
  end

  def manage_game(table, :start) do
    case ready_to_start?(table) do
      {false, error} ->
        {:error, error}

      true ->
        newround =
          Round.start(
            Map.keys(Map.filter(table.players, fn {_, value} -> value.active end)),
            table.settings
          )

        {:ok,
         %Table{table | round: newround, state: TableState.update_phase(table.state, :in_round)}}
    end
  end
  
  def ready_to_start?(table) do
    cond do
      table.state.phase == :in_round -> {false, :ongoing_round}
      Enum.count(Map.values(table.players), & &1.active) < 2 -> {false, :too_few_players}
      true -> true
    end
  end

  # TODO: check inround!!!
  def make_move(table, player_id, move) do
    if Map.has_key?(table.players, player_id) do
      case Round.make_move(table.round, player_id, move) do
        {:ok, {info, round}} -> {:ok, handle_update({info, round}, table)}
        {:error, error} -> {:error, error}
      end
    else
      {:error, :invalid_player_id}
    end
  end

  def update_connected_players(table, joins, leaves) do
    %Table{
      table
      | players:
          table.players
          |> Map.new(fn {k, v} -> {k, Player.update_connected(v, true, joins)} end)
          |> Map.new(fn {k, v} -> {k, Player.update_connected(v, false, leaves)} end)
    }
  end

  defp handle_update({info, round}, table) do
    new_table = %Table{table | round: round}
    Enum.reduce(Enum.reverse(info), new_table, &handle_instruction(&2, &1))
  end

  defp handle_instruction(table, {:result, result}) do
    %Table{
      table
      | state:
          table.state
          |> TableState.update_phase(:end_of_round)
          |> TableState.update_stats(result)
    }
  end

  defp generate_table_id() do
    :crypto.strong_rand_bytes(15) |> Base.url_encode64()
  end
end
