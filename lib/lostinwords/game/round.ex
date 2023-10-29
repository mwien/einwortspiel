defmodule Lostinwords.Game.Round do
  alias __MODULE__
  alias Lostinwords.Generator

  # TODO: maybe use state machine

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
  def start(players, settings) do
    words = Generator.gen_words(settings.nr_leftwords + settings.nr_lostwords)
    players = Enum.shuffle(players)

    create_round(
      Enum.take(words, settings.nr_leftwords),
      Enum.take(words, -settings.nr_lostwords),
      Enum.take(players, settings.nr_cluers),
      Enum.take(players, settings.nr_cluers - length(players))
    )
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

  def move(round, player, move) do
    case handle_move(round, player, move) do
      {:ok, round} ->
        {:ok,
         round
         |> update_phase()
         |> emit_info()}
      {:error, error} ->
        {:error, error}
    end
  end

  def handle_move(round, player, {:submit_clue, clue}) do
    if Enum.member?(round.cluers, player) and round.phase == "clues" do
      {:ok,
       %Round{
         round
         | clues: Map.put(round.clues, player, clue),
           waiting_for: List.delete(round.waiting_for, player)
       }}
    else
      {:error, :unauthorized_move}
    end
  end

  def handle_move(round, player, {:submit_guess, guess}) do
    if Enum.member?(round.guessers, player) and round.phase == "guesses" do
      success = Enum.member?(round.unguessed_words[player], guess)
      {:ok,
       %Round{
         round
         | guesses: Map.update(round.guesses, player, [guess], &List.insert_at(&1, 0, guess)),
           unguessed_words: Map.update!(round.unguessed_words, player, &List.delete(&1, guess))
       }
       |> check_finished(player, success)
       |> update_score(player, success)}
    else
      {:error, :unauthorized_move}
    end
  end

  def handle_move(_round, _player, _) do
    {:error, :unknown_move}
  end

  def check_finished(round, player, success) do
    if !success or Enum.empty?(round.unguessed_words[player]) do
      %Round{round | waiting_for: List.delete(round.waiting_for, player)}
    else
      round
    end
  end

  def update_score(round, player, success) do
    if success do
      Enum.reduce(
        round.cluers,
        add_info(round, {:plus_score, player, score("guesser")}),
        &add_info(&2, {:plus_score, &1, score("cluer")})
      )
    else
      round
    end
  end

  # can be extended later
  def score(role) do
    case role do
      "guesser" -> 1
      "cluer" -> 1
    end
  end

  # TODO: implement skip with proper state machine!
  def update_phase(round) do
    if !Enum.empty?(round.waiting_for) do
      round
    else
      case round.phase do
        "clues" ->
          %{round | phase: "guesses"}
          |> Map.put(:waiting_for, round.guessers)

        "guesses" ->
          %{round | phase: "final"}
          |> Map.put(:waiting_for, [])
          |> add_info({:end_of_round})

        "final" ->
          round
      end
    end
  end

  defp add_info(round, payload) do
    %Round{round | info: [payload | round.info]}
  end

  defp emit_info(round) do
    {round.info, %Round{round | info: []}}
  end
end
