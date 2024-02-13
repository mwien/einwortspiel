defmodule Einwortspiel.Game.WordsTest do
  use ExUnit.Case
  alias Einwortspiel.Game.Words

  test "words for three players" do
    players = ["Marcel", "Clara", "Nora"]
    settings = %{nr_commonwords: 2, language: "de"}
    words = Words.generate(players, settings)

    for p1 <- players, p2 <- players, p1 != p2 do
      w1 = MapSet.new(Words.get_words(words, p1))
      w2 = MapSet.new(Words.get_words(words, p2))
      assert MapSet.intersection(w1, w2) |> MapSet.size() == 2
    end

    assert Enum.map(players, &Words.get_words(words, &1)) |> List.flatten() |> Enum.uniq() |> length() == 5
  end
end
