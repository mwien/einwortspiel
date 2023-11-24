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

  def open_table() do
    %Table{
      table_id: generate_table_id(),
      round: nil,
      players: %{}, 
      settings: Settings.default_settings(),
      state: TableState.create_state()
    }
  end

  def join(table, player_id) do
    if !Map.has_key?(table.players, player_id) do
      {:ok, 
        %Table{table | 
          players: Map.put(table.players, player_id, Player.create_player(player_id))
        } 
      }
    else
      # should this be error? -> maybe remove this
      {:error, :already_joined}
    end
  end

  def manage_round(table, :start) do
    cond do
      table.state.phase == :in_round -> 
        {:error, :ongoing_round}
      length(Map.keys(Map.filter(table.players, fn {_, value} -> !value.spectator end))) < 2 -> 
        {:error, :too_few_players}
      true -> 
        newround = Round.start(Map.keys(Map.filter(table.players, fn {_, value} -> !value.spectator end)), table.settings)
        {:ok, %Table{table | round: newround, state: TableState.update_phase(table.state, :in_round)}}
    end
  end

  def set_attribute(table, player_id, attribute, value) do
    if Map.has_key?(table.players, player_id) do
      {:ok,
        %Table{table | 
          players: Map.put(table.players, player_id, Player.update_player(table.players[player_id], attribute, value))
        }
      }
    else
      {:error, :invalid_player_id}
    end
  end

  # TODO: check inround!!!
  def move(table, player_id, move) do
    if Map.has_key?(table.players, player_id) do
      case Round.move(table.round, player_id, move) do
        {:ok, {info, round}} -> {:ok, handle_update({info, round}, table)}
        {:error, error} -> {:error, error}
      end  
    else
      {:error, :invalid_player_id}   
    end
  end

  def update_active_players(table, joins, leaves) do
    %Table{table |
      players: table.players
      |> Map.new(fn {k, v} -> {k, Player.update_active(v, true, joins)} end)
      |> Map.new(fn {k, v} -> {k, Player.update_active(v, false, leaves)} end)
    }
  end

  defp handle_update({info, round}, table) do
    new_table = %Table{table | round: round}
    Enum.reduce(Enum.reverse(info), new_table, &handle_instruction(&2, &1))
  end

  defp handle_instruction(table, {:result, result}) do
    %Table{table | state: 
      table.state
      |> TableState.update_phase(:end_of_round)
      |> TableState.update_stats(result)
    }
  end

  defp generate_table_id() do
    :crypto.strong_rand_bytes(15) |> Base.url_encode64()
  end
end
