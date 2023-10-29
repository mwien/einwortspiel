defmodule Lostinwords.Game.Table do
  alias __MODULE__
  alias Lostinwords.Game.Player
  alias Lostinwords.Game.Round
  alias Lostinwords.Game.Settings

  defstruct [
    :table_id,
    :round,
    :players,
    :settings,
    :state,
    :info
  ]

  def open_table() do
    %Table{
      table_id: generate_table_id(),
      round: nil,
      players: %{}, 
      settings: Settings.default_settings(),
      state: :init,
      info: []
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
      table.state == :in_round -> 
        {:error, :ongoing_round}
      length(Map.keys(table.players)) < 2 -> 
        {:error, :too_few_players}
      true -> 
        newround = Round.start(Map.keys(table.players), table.settings)
        {:ok, %Table{table | round: newround, state: :in_round}}
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

  defp handle_instruction(table, {:plus_score, player, plus_score}) do
    %Table{table | players: Map.put(table.players, player, Player.update_score(table.players[player], plus_score))}
  end
  
  defp handle_instruction(table, {:end_of_round}) do
    %Table{table | state: :end_of_round}
  end

  defp generate_table_id() do
    :crypto.strong_rand_bytes(15) |> Base.url_encode64()
  end
end
