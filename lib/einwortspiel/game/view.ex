defmodule Einwortspiel.Game.View do
  alias __MODULE__
  alias Einwortspiel.Game.{Info, Player, Round, State, Words}

  # TODO:
  # - remove connected here -> add to game room
  # - have option for player to leave as well (set to inactive) in game.ex

  # add further typespecs for general and player -> maybe in submodules?
  defstruct [
    :general,
    :players
  ]

  def get_view(game) do
    %View{general: get_general(game), players: get_players(game)}
  end

  defp get_general(%State{round: nil} = game) do
    %{
      can_start_round: if(State.can_start_round(game) == :ok, do: true, else: false),
      phase: :init,
      wins: 0,
      losses: 0
    }
  end

  defp get_general(game) do
    %{
      can_start_round: if(State.can_start_round(game) == :ok, do: true, else: false),
      phase: Round.get_phase(game.round),
      wins: Info.get_wins(game.info),
      losses: Info.get_losses(game.info)
    }
  end

  defp get_player(game, player_id) do
    if game.round == nil or !State.Round.has_player?(game.round, player_id) do
      %{
        id: player_id,
        name: Player.get_name(game.players[player_id]),
        connected: Player.get_connected(game.players[player_id]),
        active: Player.get_active(game.players[player_id]),
        words: nil,
        clue: nil,
        guess: nil
      }
    else
      %{
        id: player_id,
        name: Player.get_name(game.players[player_id]),
        active: Player.get_active(game.players[player_id]),
        connected: Player.get_connected(game.players[player_id]),
        words: word_view(game, player_id),
        clue: Round.get_clue(game.round, player_id),
        guess: Round.get_guess(game.round, player_id)
      }
    end
  end

  defp get_players(game) do
    Enum.reduce(Map.keys(game.players), %{}, &Map.put(&2, &1, get_player(game, &1)))
  end

  def update_general(new_game, old_game) do
    put_in(
      new_game.update.general,
      filter_changed(get_general(new_game), get_general(old_game))
    )
  end

  def update_player(new_game, old_game, player_id) do
    put_in(
      new_game.update.players[player_id],
      filter_changed(get_player(new_game, player_id), get_player(old_game, player_id))
    )
  end

  def update_new_player(game, player_id) do
    put_in(
      game.update.players[player_id],
      get_player(game, player_id)
    )
  end

  defp filter_changed(map1, map2) do
    Map.filter(map1, fn {k, v} -> v != map2[k] end)
  end

  defp word_view(game, player_id) do
    words = Round.get_words(game.round)
    extraword = Words.get_extraword(words, player_id)

    Words.get_words(words, player_id)
    |> Enum.map(fn word -> {word, word == extraword} end)
  end
end
