defmodule Einwortspiel.State.StateTest do
  use ExUnit.Case

  alias Einwortspiel.Game.State

  test "simulate_game" do
    room_id = "test_room"
    # TODO: maybe just commonwords: 2 
    options = %{nr_commonwords: 2, language: "de"}
    state = State.init(room_id, options)
    assert {:ok, {_update, state}} = State.add_player(state, "id1234", "Marcel")
    assert {:error, :player_id_exists} = State.add_player(state, "id1234", "Clara")
    assert {:error, :too_few_players} = State.start_round(state, "id1234")
    assert {:ok, {_update, state}} = State.add_player(state, "id5678", "Clara")
    assert {:ok, {_update, state}} = State.start_round(state, "id1234")
    assert {:ok, {_update, state}} = State.process_clue(state, "id1234", "Fuchs")
    assert {:ok, {_update, state}} = State.process_clue(state, "id5678", "Lachs")
    assert {:ok, {_update, state}} = State.process_guess(state, "id1234", "Xyz")
    assert {:ok, {_update, state}} = State.process_guess(state, "id5678", "Xyz")
    assert {:ok, {_update, _state}} = State.start_round(state, "id5678")
  end
end
