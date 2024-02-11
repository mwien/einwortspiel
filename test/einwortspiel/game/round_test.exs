defmodule Einwortspiel.Game.RoundTest do
  use ExUnit.Case
  alias Einwortspiel.Game.{Round, Words}

  test "round for two players" do
    players = ["Marcel", "Clara"]
    settings = %{nr_commonwords: 2, language: "de"}
    round = Round.init(players, settings)
    assert Round.get_phase(round) == :clues 
    words = Round.get_words(round)
    {:ok, round} = Round.make_move(round, "Marcel", {:submit_clue, "Schmetterling"})
    assert Round.get_clue(round, "Marcel") == "Schmetterling"
    assert Round.get_phase(round) == :clues
    {:ok, round} = Round.make_move(round, "Clara", {:submit_clue, "Taubenschlag"})
    assert Round.get_clue(round, "Clara") == "Taubenschlag"
    assert Round.get_phase(round) == :guesses
    {:ok, round} = Round.make_move(round, "Marcel", {:submit_guess, Words.get_extraword(words, "Marcel")})
    assert Round.get_phase(round) == :guesses
    {:ok, winning_round} = Round.make_move(round, "Clara", {:submit_guess, Words.get_extraword(words, "Clara")})
    assert Round.get_phase(winning_round) == :win
    {:ok, losing_round} = Round.make_move(round, "Clara", {:submit_guess, "xyz"})
    assert Round.get_phase(losing_round) == :loss
  end
end
