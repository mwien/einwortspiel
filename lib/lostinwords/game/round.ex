defmodule Lostinwords.Game.Round do
  alias __MODULE__
  alias Lostinwords.Generator

  # TODO: maybe use state machine

  # add typespecs later if ever
  defstruct [
    :commonwords,
    :extrawords,
    :shuffle,
    :players, 
    :phase,
    :waiting_for,
    :clues,
    :guesses,
    :info,
  ]

  def start(players, settings) do
    words = Generator.gen_words(settings.nr_commonwords + length(players))
    create_round(
      Enum.take(words, settings.nr_commonwords),
      Enum.take(words, -length(players)),
      players
    )
  end

  def create_round(commonwords, extrawords, players) do
    %Round{
      commonwords: commonwords,
      extrawords: Map.new(Enum.zip(players, extrawords)),
      shuffle: Map.new(players, fn x -> {x, Enum.shuffle([0, 1, 2])} end),
      players: players,
      phase: "clues",
      waiting_for: players,
      clues: %{},
      guesses: %{},
      info: [],
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
    if Enum.member?(round.waiting_for, player) and round.phase == "clues" do
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
    if Enum.member?(round.waiting_for, player) and round.phase == "guesses" do
      {:ok,
       %Round{
         round
         | guesses: Map.put(round.guesses, player, guess),
          waiting_for: List.delete(round.waiting_for, player)
       }
      }
    else
      {:error, :unauthorized_move}
    end
  end

  def handle_move(_round, _player, _) do
    {:error, :unknown_move}
  end

  # TODO: implement skip with proper state machine!
  def update_phase(round) do
    if !Enum.empty?(round.waiting_for) do
      round
    else
      case round.phase do
        "clues" ->
          %{round | phase: "guesses"}
          |> Map.put(:waiting_for, Map.keys(round.extrawords))

        "guesses" ->
          %{round | phase: "final"}
          |> Map.put(:waiting_for, [])
          |> add_info({:result, round.guesses == round.extrawords})

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
