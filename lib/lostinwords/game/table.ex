defmodule Lostinwords.Game.Table do
  alias __MODULE__
  alias Lostinwords.Game.Round

  defstruct [
    :table_id,
    :current_round,
    :all_players,
    :active_players,
    :names,
    :animals,
    :scores,
    :settings,
    :info
  ]

  def open_table() do
    %Table{
      table_id: generate_table_id(),
      current_round: nil,
      all_players: [],
      active_players: [],
      names: %{},
      animals: %{},
      scores: %{},
      settings: %{nr_leftwords: 3, nr_lostwords: 1, nr_cluers: 1},
      info: []
    }
  end
  
  def join(table, player_id) do
    if !Enum.member?(table.all_players, player_id) do
      table = %Table{
        table
        | all_players: [player_id | table.all_players],
          scores: Map.put_new(table.scores, player_id, 0)
      }
      {name, animal} = Lostinwords.Generator.gen_animal()
      {:ok, table} = set_attribute(table, player_id, :name, name)
      {:ok, table} = set_attribute(table, player_id, :animal, animal)
      {:ok, table}
    else
      {:error, :already_joined}
    end
  end
  
  def manage_round(table, :start) do
    # TODO: add check that round can be started
    # -> have something like table state 
    {:ok, Round.start(table.all_players, table.settings)}
  end
  
  def set_attribute(table, player_id, attribute, value) do
    if Enum.member?(table.all_players, player_id) do
      # TODO: improve this!
      {:ok, case attribute do
        :name -> %Table{table | names: Map.put(table.names, player_id, value)}
        :animal -> %Table{table | animals: Map.put(table.animals, player_id, value)}
      end
      }
    else 
      {:error, :invalid_player_id}
    end
  end

  def move(table, player_id, move) do
    # TODO: have checks here?
    # like whether player exists?
    case Round.move(table.current_round, player_id, move) do
      {:ok, info, round} -> {:ok, handle_update({info, round}, table)}
      {:error, error} -> {:error, error}
    end
  end

  def update_active_players(table, joins, leaves) do
    active_after_join = Enum.reduce(Map.keys(joins), table.active_players, &([&1 | &2]))
    active_after_leave = Enum.reduce(Map.keys(leaves), active_after_join, &Enum.filter(&2, fn x -> x != &1 end))
    %Table{ table | active_players: active_after_leave }
    # |> check_continue_and_notify()
  end

# TODO: redo this as skip
# or more generally have admin user, which can do this stuff
# # why double emit info -> make this clean
#  def continue(table) do
#    if table.current_round == nil do
#      table
#    else   
#      Round.continue(table.current_round, table.active_players)
#      |> handle_update(table)
#      |> emit_info()
#    end
#  end

  defp handle_update({info, round}, table) do
    new_table = %Table{table | current_round: round}
    Enum.reduce(Enum.reverse(info), new_table, &handle_instruction(&2, &1))
  end

  defp handle_instruction(table, {:plus_score, player, plus_score}) do
    new_score = table.scores[player] + plus_score
    %Table{table | scores: Map.put(table.scores, player, new_score)}
  end
  
  defp generate_table_id() do
    :crypto.strong_rand_bytes(15) |> Base.url_encode64()
  end
end
