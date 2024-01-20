defmodule Einwortspiel.Game.Round do
  alias __MODULE__
  alias Einwortspiel.Generator

  # TUDU: maybe use state machine for game state (and maybe notifications)

  defstruct [
    :allwords,
    :extrawords,
    :phase,
    :waiting_for,
    :clues,
    :guesses,
    :info
  ]

  def start(players, settings) do
    words = Generator.gen_words(settings.nr_commonwords + length(players), settings.language)

    create_round(
      Enum.take(words, settings.nr_commonwords),
      Enum.take(words, -length(players)),
      players
    )
  end

  def create_round(commonwords, extrawords, players) do
    extrawords = Map.new(Enum.zip(players, extrawords))

    %Round{
      allwords:
        Map.new(extrawords, fn {player, extraword} ->
          {player, Enum.shuffle([extraword | commonwords])}
        end),
      extrawords: extrawords,
      phase: :clues,
      waiting_for: MapSet.new(players),
      clues: %{},
      guesses: %{},
      info: []
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
    if MapSet.member?(round.waiting_for, player) and round.phase == :clues do
      {:ok,
       %Round{
         round
         | clues: Map.put(round.clues, player, clue),
           waiting_for: MapSet.delete(round.waiting_for, player)
       }}
    else
      {:error, :unauthorized_move}
    end
  end

  def handle_move(round, player, {:submit_guess, guess}) do
    if MapSet.member?(round.waiting_for, player) and round.phase == :guesses do
      {:ok,
       %Round{
         round
         | guesses: Map.put(round.guesses, player, guess),
           waiting_for: MapSet.delete(round.waiting_for, player)
       }}
    else
      {:error, :unauthorized_move}
    end
  end

  def handle_move(_round, _player, _) do
    {:error, :unknown_move}
  end

  def update_phase(round) do
    if !Enum.empty?(round.waiting_for) do
      round
    else
      case round.phase do
        :clues ->
          %{round | phase: :guesses}
          |> Map.put(:waiting_for, MapSet.new(Map.keys(round.extrawords)))

        :guesses ->
          result = if round.guesses == round.extrawords, do: :win, else: :loss

          %{round | phase: result}
          |> Map.put(:waiting_for, MapSet.new())
          |> add_info({:result, result})

        :win ->
          round

        :loss ->
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
