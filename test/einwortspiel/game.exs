defmodule Einwortspiel.GameTest do
  use ExUnit.Case 
  doctest Einwortspiel.Game 

  test "simulate_game" do
    game = Game.init()
    assert {[{:new_player, "id1234", _player}], game} = Game.add_player(game, "id1234", "Marcel")
    assert {[{:new_player, "id9876", _player}], game} = Game.add_player(game, "id9876", "Clara")
    {notifications, game} = Game.start_round(game, "id1234")
    assert game.round != nil
    # TODO: continue 
  end
end
