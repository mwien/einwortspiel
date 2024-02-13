defmodule Einwortspiel.Game.Round do
  alias __MODULE__
  alias Einwortspiel.Game.Words

  defstruct [
    :phase,
    :players,
    :waiting_for,
    :words,
    :clues,
    :guesses,
  ]

  def init(players, settings) do
    %Round{
      phase: :clues,
      players: players,
      waiting_for: MapSet.new(players),
      words: Words.generate(players, settings), 
      clues: %{},
      guesses: %{}
    } 
  end
  
  def has_player?(round, player), do: Enum.member?(round.players, player)
  def get_phase(round), do: round.phase 
  def get_words(round), do: round.words
  def get_clue(round, player), do: Map.get(round.clues, player)
  def get_guess(round, player), do: Map.get(round.guesses, player)

  def make_move(round, player, move) do
    case handle_move(round, player, move) do
      {:ok, round} ->
        {:ok,
         update_phase(round)
        }

      {:error, error} ->
        {:error, error}
    end
  end

  defp handle_move(round, player, {:submit_clue, clue}) do
    if MapSet.member?(round.waiting_for, player) and round.phase == :clues do
      {:ok,
       %Round{
         round
         | clues: Map.put(round.clues, player, clue),
           waiting_for: MapSet.delete(round.waiting_for, player),
       }
      }
    else
      {:error, :unauthorized_move}
    end
  end

  defp handle_move(round, player, {:submit_guess, guess}) do
    if MapSet.member?(round.waiting_for, player) and round.phase == :guesses do
      {:ok,
       %Round{
         round
         | guesses: Map.put(round.guesses, player, guess),
           waiting_for: MapSet.delete(round.waiting_for, player),
       }
      }
    else
      {:error, :unauthorized_move}
    end
  end

  defp handle_move(_round, _player, _) do
    {:error, :unknown_move}
  end

  defp update_phase(round) do
    if !Enum.empty?(round.waiting_for) do
      round
    else
      case round.phase do
        :clues ->
          %Round{round | 
            phase: :guesses, 
            waiting_for: MapSet.new(round.players)
          }

        :guesses ->
          %Round{round | 
            phase: (if guesses_correct?(round), do: :win, else: :loss), 
            waiting_for: MapSet.new()
          }

        :win ->
          round

        :loss ->
          round
      end
    end
  end

  defp guesses_correct?(round) do
    Enum.all?(round.players, fn player -> 
      get_guess(round, player) == Words.get_extraword(round.words, player)
    end)
  end
end
