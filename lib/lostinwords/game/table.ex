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

  def start_round(table) do
    Round.start(table.all_players, table.settings)
    |> handle_update(table)
    |> emit_info()
  end

  def move(table, player_id, move) do
    Round.move(table.current_round, player_id, move)
    |> handle_update(table)
    |> emit_info()
  end

 # why double emit info -> make this clean
  def continue(table) do
    if table.current_round == nil do
      table
    else   
      Round.continue(table.current_round, table.active_players)
      |> handle_update(table)
      |> emit_info()
    end
  end

  def join(table, player_id) do
    if !Enum.member?(table.all_players, player_id) do
      %Table{
        table
        | all_players: [player_id | table.all_players],
          scores: Map.put_new(table.scores, player_id, 0)
      }
      |> notify_all({:info_player_joined, player_id})
      |> emit_info()
    else
      table
      |> emit_info()
    end
  end

  def set_animal(table, player_id, animal) do
    %Table{table | animals: Map.put(table.animals, player_id, animal)}
    |> notify_all({:info_animal_set, player_id, animal})
    |> emit_info()
  end

  def set_name(table, player_id, name) do
    %Table{table | names: Map.put(table.names, player_id, name)}
    |> notify_all({:info_name_set, player_id, name})
    |> emit_info()
  end

  def update_active_players(table, joins, leaves) do
    afterjoin = Enum.reduce(Map.keys(joins), table.active_players, &([&1 | &2]))
    afterleave = Enum.reduce(Map.keys(leaves), afterjoin, &Enum.filter(&2, fn x -> x != &1 end))
    %Table{ table | active_players: afterleave }
    |> check_continue_and_notify()
    |> emit_info()
    
  end

  # make this more efficient -> i.e. don't send every time and also wait for a few seconds TODO
  defp check_continue_and_notify(table) do
    if table.current_round == nil do
      table  
    else
      if Round.waiting_for_active(table.current_round, table.active_players) do
        notify_all(table, {:info_continue, false}) 
      else
        notify_all(table, {:info_continue, true})
      end
    end
  end

  defp handle_update({instructions, round}, table) do
    new_table = %Table{table | current_round: round}
    Enum.reduce(Enum.reverse(instructions), new_table, &handle_instruction(&2, &1))
  end

  defp handle_instruction(table, {:notify_table, {:plus_score, player, plus_score}}) do
    new_score = table.scores[player] + plus_score

    %Table{table | scores: Map.put(table.scores, player, new_score)}
    |> notify_all({:info_score, player, plus_score, new_score})
  end

  defp handle_instruction(table, instruction) do
    %Table{table | info: [instruction | table.info]}
  end

  def construct_assigns(table, player_id) do
    if table.current_round == nil do
      %{
        names: table.names,
        animals: table.animals,
        scores: table.scores,
        active_players: table.active_players,
        roles: %{},
        words: [],
        received_clues_from: [],
        clues: %{},
        received_guesses_from: [],
        guesses: %{},
        finished: [],
        phase: "not_started",
        lostwords: [],
        continue: false
      }
    else
      %{
        names: table.names,
        animals: table.animals,
        scores: table.scores,
        active_players: table.active_players,
        roles: Round.get_roles(table.current_round),
        words: Round.get_words(table.current_round, player_id),
        received_clues_from: Round.get_rec_clues(table.current_round),
        clues: Round.get_clues(table.current_round, player_id),
        received_guesses_from: Round.get_rec_guesses(table.current_round),
        guesses: Round.get_guesses(table.current_round, player_id),
        finished: Round.get_finishers(table.current_round),
        phase: Round.get_phase(table.current_round),
        lostwords: Round.get_lostwords(table.current_round),
        continue: Round.waiting_for_active(table.current_round, table.active_players)
      }
    end
  end

  defp generate_table_id() do
    :crypto.strong_rand_bytes(15) |> Base.url_encode64()
  end

  # think about how to do this -> avoid duplicate code
  defp notify_all(table, payload) do
    Enum.reduce(table.all_players, table, &notify_player(&2, &1, payload))
  end

  defp notify_player(table, player, payload) do
    %Table{table | info: [{:notify_player, player, payload} | table.info]}
  end

  defp emit_info(table) do
    # double check order of info
    {table.info, %Table{table | info: []}}
  end
end
