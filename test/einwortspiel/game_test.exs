defmodule Einwortspiel.GameTest do
  use ExUnit.Case

  alias Einwortspiel.Game

  # TODO: improve test case
  test "simulate_game" do
    game_id = "top_class_game"
    options = %{nr_commonwords: 2, language: "de"}
    game = Game.init(game_id, options)
    assert {:ok, {_update, game}} = Game.add_player(game, "id1234", "Marcel")
    assert {:error, :player_id_exists} = Game.add_player(game, "id1234", "Clara")
    assert {:error, :too_few_players} = Game.start_round(game, "id1234")
    assert {:ok, {_update, game}} = Game.add_player(game, "id5678", "Clara")
    assert {:ok, {_update, game}} = Game.start_round(game, "id1234")
    assert {:ok, {_update, game}} = Game.submit_clue(game, "id1234", "Fuchs")
    assert {:ok, {_update, game}} = Game.submit_clue(game, "id5678", "Lachs")
    assert {:ok, {_update, game}} = Game.submit_guess(game, "id1234", "Xyz")
    assert {:ok, {_update, game}} = Game.submit_guess(game, "id5678", "Xyz")
    assert {:ok, {_update, _game}} = Game.start_round(game, "id5678")
  end
end
