defmodule Einwortspiel.Game.Round do
  alias __MODULE__
  alias Einwortspiel.Game.Words

  defstruct [
    :phase,
    :waiting_for,
    :words,
    :clues,
    :guesses,
    :changed,
    :info
  ]

  def init(players, settings) do
    %Round{
      phase: :clues,
      waiting_for: MapSet.new(players),
      words: Words.generate(players, settings), 
      clues: %{},
      guesses: %{},
      changed: [],
      info: []
    } 
  end

  def start(players, settings) do
    init(players, settings)
    |> add_changed(:general)
    |> then(&Enum.reduce(players, &1, fn player, round -> add_changed(round, player) end))
    |> emit_changed_and_info()
  end

  def make_move(round, player, move) do
    case handle_move(round, player, move) do
      {:ok, round} ->
        {:ok,
         round
         |> update_phase()
         |> emit_changed_and_info()}

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
           waiting_for: MapSet.delete(round.waiting_for, player),
       }
       |> add_changed(player)
      }
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
           waiting_for: MapSet.delete(round.waiting_for, player),
       }
       |> add_changed(player)
      }
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
          |> add_changed(:general)
          |> add_info({:result, result})

        :win ->
          round

        :loss ->
          round
      end
    end
  end

  defp add_changed(round, object) do
    %Round{round | changed: [object | round.changed]}
  end
  
  defp add_info(round, payload) do
    %Round{round | info: [payload | round.info]}
  end

  defp emit_changed_and_info(round) do
    {round.info, round.changed, %Round{round | info: [], changed: []}}
  end
end
