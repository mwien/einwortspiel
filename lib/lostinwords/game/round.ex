defmodule Lostinwords.Game.Round do
  alias __MODULE__
  alias Lostinwords.Generator

  # add typespecs later if ever

  defstruct [
    :leftwords,
    :fullwords,
    :phase,
    :cluers,
    :guessers,
    :waiting_for,
    :info,
    :clues,
    :guesses,
    :unguessed_words
  ]

  # make cluer not random, but shuffle through
  def start(
        players,
        %{nr_leftwords: nr_leftwords, nr_lostwords: nr_lostwords, nr_cluers: nr_cluers} =
          _settings
      ) do
    # scores = Map.new(players, &({&1, 0}))
    words = Generator.gen_words(nr_leftwords + nr_lostwords)
    players = Enum.shuffle(players)

    create_round(
      Enum.take(words, nr_leftwords),
      Enum.take(words, -nr_lostwords),
      Enum.take(players, nr_cluers),
      Enum.take(players, nr_cluers - length(players))
    )
    |> initial_info()
    |> emit_info()
  end

  def create_round(leftwords, lostwords, cluers, guessers) do
    %Round{
      leftwords: Enum.shuffle(leftwords),
      fullwords: Enum.shuffle(leftwords ++ lostwords),
      phase: "clues",
      cluers: cluers,
      guessers: guessers,
      waiting_for: cluers,
      info: [],
      clues: %{},
      guesses: %{},
      unguessed_words: Map.new(guessers, fn g -> {g, lostwords} end)
    }
  end

  def initial_info(round) do
    round
    |> notify_all({:info_new_phase, "clues"})
    |> notify_all({:info_roles, get_roles(round)})
    |> notify_players(round.cluers, {:info_words, round.leftwords})
    |> notify_players(round.guessers, {:info_words, round.fullwords})
  end

  def move(round, player, move) do
    round
    |> handle_move(player, move)
    |> update_phase()
    |> emit_info()
  end

  def handle_move(round, player, {:submit_clue, clue}) do
    if Enum.member?(round.cluers, player) and round.phase == "clues" do
      %Round{
        round
        | clues: Map.put(round.clues, player, clue),
          waiting_for: List.delete(round.waiting_for, player)
      }
      |> notify_all({:info_received_clue, player})
    else
      round
      |> notify_player(player, {:info_unauthorized_move})
    end
  end

  def handle_move(round, player, {:submit_guess, guess}) do
    if Enum.member?(round.guessers, player) and round.phase == "guesses" do
      success = Enum.member?(round.unguessed_words[player], guess)

      %Round{
        round
        | guesses: Map.update(round.guesses, player, [guess], &List.insert_at(&1, 0, guess)),
          unguessed_words: Map.update!(round.unguessed_words, player, &List.delete(&1, guess))
      }
      |> notify_all(
        {:info_received_guess, player,
         if success do
           "correct"
         else
           "incorrect"
         end}
      )
      |> check_finished(player, success)
      |> keep_score(player, success)
    else
      round
      |> notify_player(player, {:info_unauthorized_move})
    end
  end

  def handle_move(round, player, _) do
    round
    |> notify_player(player, {:info_unauthorized_move})
  end

  def check_finished(round, player, success) do
    if !success or Enum.empty?(round.unguessed_words[player]) do
      %Round{round | waiting_for: List.delete(round.waiting_for, player)}
      |> notify_all({:info_finished, player})
    else
      round
    end
  end

  def keep_score(round, player, success) do
    if success do
      Enum.reduce(
        round.cluers,
        notify_table(round, {:plus_score, player, score("guesser")}),
        &notify_table(&2, {:plus_score, &1, score("cluer")})
      )
    else
      round
    end
  end

  # can be extended later -> e.g. include finish info in score change
  def score(role) do
    cond do
      role == "guesser" -> 10
      role == "cluer" -> 5
    end
  end

  # TODO: fix continue that it is cleared after new phase!!!
  def update_phase(round) do
    if !Enum.empty?(round.waiting_for) do
      round
    else
      case round.phase do
        "clues" ->
          %{round | phase: "guesses"}
          |> notify_all({:info_clues, round.clues})
          |> notify_all({:info_new_phase, "guesses"})
          |> Map.put(:waiting_for, round.guessers)

        "guesses" ->
          round = %{round | phase: "final"}
          round 
          |> notify_all({:info_guesses, round.guesses})
          |> notify_all({:info_lostwords, get_lostwords(round)}) 
          |> notify_all({:info_new_phase, "final"})
          |> Map.put(:waiting_for, [])

        "final" ->
          round
      end
    end
  end

  # maybe broadcasting will be used at some point
  # for now I think this way is most flexible
  # as it can easily support multiple means of communication
  # i.e. player 1 could be connected via pubsub
  # and player 2 in some different way (maybe it is a bot player etc)
  defp notify_all(round, payload) do
    notify_players(round, round.cluers ++ round.guessers, payload)
  end

  defp notify_players(round, players, payload) do
    Enum.reduce(players, round, &notify_player(&2, &1, payload))
  end

  defp notify_player(round, player, payload) do
    %Round{round | info: [{:notify_player, player, payload} | round.info]}
  end

  defp notify_table(round, payload) do
    %Round{round | info: [{:notify_table, payload} | round.info]}
  end

  defp emit_info(round) do
    {round.info, %Round{round | info: []}}
  end

  def get_roles(round) do
    Map.merge(Map.new(round.cluers, &{&1, "cluer"}), Map.new(round.guessers, &{&1, "guesser"}))
  end

  def get_words(round, player) do
    if Enum.member?(round.cluers, player) do
      round.leftwords
    else
      round.fullwords
    end
  end

  def get_rec_clues(round) do
    Map.keys(round.clues)
  end

  def get_clues(round, player) do
    # make this nicer!
    # encode phase by numbers would make this simpler
    if round.phase == "guesses" or round.phase == "final" do
      round.clues
    else
      case round.clues[player] do
        nil -> %{}
        own_clue -> %{player => own_clue}
      end
    end
  end

  def get_rec_guesses(round) do
    Map.keys(round.guesses)
  end

  def get_guesses(round, player) do
    # make this nicer!
    # encode phase by numbers would make this simpler
    if round.phase == "final" do
      round.guesses
    else
      case round.guesses[player] do
        nil -> %{}
        own_guess -> %{player => own_guess}
      end
    end
  end

  def get_lostwords(round) do
    if round.phase == "final" do
      Enum.filter(round.fullwords, &(!Enum.member?(round.leftwords, &1)))
    else
      []
    end
  end

  def get_finishers(_round) do
    # TODO!
    []
  end

  def get_phase(round) do
    round.phase
  end

  def waiting_for_active(round, active_players) do
    !Enum.empty?(Enum.filter(round.waiting_for, &Enum.member?(active_players, &1)))
  end

  # maybe handle as move with player and info_unauthorized_move??
  # but maybe also not
  # double phase update is bit ugly
  # is basically a skip to the final phase (-> implement directly)
  def continue(round, active_players) do 
     if waiting_for_active(round, active_players) do 
       round  
    else
      %Round{ round | waiting_for: [] }
      |> update_phase()
      |> Map.put(:waiting_for, [])
      |> update_phase()
    end
    |> emit_info()
  end

end
