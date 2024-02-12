defmodule Einwortspiel.Game do
  alias __MODULE__
  alias Einwortspiel.Game.{Round, Info, Player, Settings, Words}
  
  defstruct [
    :id,
    :info,
    :players,
    :round,
    :settings,
    :update
  ]

  def init(game_id, options) do
    %Game{
      id: game_id,
      info: Info.init(),
      players: %{},
      round: nil,
      settings: Settings.init(options),
      update: {%{}, %{}}
    }
  end

  # TODO: detailed documentation!
  def game_view(game) do
    {get_general(game), get_players(game)}
  end
 
  def add_player(game, player_id, name) do
    if !has_player?(game, player_id) do
      {:ok, 
        %Game{game | 
          players: Map.put(game.players, player_id, Player.create(name))
        }
        |> update_new_player(player_id)
        |> update_general(game) 
        |> emit_update()
      }
    else
      {:error, :player_id_exists}
    end
  end

  def start_round(game, _player_id) do
    case can_start_round(game) do
      :ok -> new_game = %Game{game | 
          round: Round.init(Map.keys(game.players), game.settings)
        } 
        {:ok, {game_view(new_game), new_game}}
      {:error, error} -> {:error, error}
    end    
  end

  def submit_clue(game, player_id, clue) do
    case Round.make_move(game.round, player_id, {:submit_clue, clue}) do
      {:ok, new_round} -> {:ok, 
          %Game{game | round: new_round}
          |> update_player(game, player_id)
          |> update_general(game)
          |> emit_update()
        }

      {:error, error} -> {:error, error}
    end
  end

  def submit_guess(game, player_id, guess) do
    case Round.make_move(game.round, player_id, {:submit_guess, guess}) do
      {:ok, new_round} -> {:ok, 
          %Game{game | 
            round: new_round, 
            info: Info.evaluate_result(game.info, Round.get_phase(new_round))
          }
          |> update_player(game, player_id)
          |> update_general(game)
          |> emit_update()
        }
      {:error, error} -> {:error, error}
    end
  end

  # TODO: take active into account
  defp can_start_round(game) do
    cond do
      map_size(game.players) < 2 -> {:error, :too_few_players}
      game.round == nil -> :ok
      Enum.member?([:clues, :guesses], Round.get_phase(game.round)) -> {:error, :ongoing_round}
      true -> :ok
    end
  end

  defp has_player?(game, player_id) do
    Map.has_key?(game.players, player_id)
  end

  defp get_general(%Game{round: nil} = game) do
    %{
      can_start_round: (if can_start_round(game) == :ok, do: true, else: false), 
      phase: :init, 
      wins: 0, 
      losses: 0
    }
  end

  defp get_general(game) do
    %{
      can_start_round: (if can_start_round(game) == :ok, do: true, else: false), 
      phase: Round.get_phase(game.round),
      wins: Info.get_wins(game.info),
      losses: Info.get_losses(game.info)
    }
  end

  defp get_player(%Game{round: nil} = game, player_id) do
    %{
      id: player_id, 
      name: Player.get_name(game.players[player_id]),
      connected: Player.get_connected(game.players[player_id]),
      active: Player.get_active(game.players[player_id]),
      words: nil,
      clue: nil,
      guess: nil
    }
  end

  defp get_player(game, player_id) do
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

  defp get_players(game) do
    Enum.reduce(Map.keys(game.players), %{}, &Map.put(&2, &1, get_player(game, &1)))
  end

  defp update_general(new_game, old_game) do
    {_general, players} = new_game.update
    new_update = {filter_changed(get_general(new_game), get_general(old_game)), players}
    %Game{new_game | update: new_update}
  end

  defp update_player(new_game, old_game, player_id) do
    {general, players} = new_game.update

    new_update = {
      general,
      Map.put(
        players,
        player_id,
        filter_changed(get_player(new_game, player_id), get_player(old_game, player_id))
      )
    }

    %Game{new_game | update: new_update}
  end
  
  defp update_new_player(game, player_id) do
    {general, players} = game.update 
    new_update = {
      general, 
      Map.put(players, player_id, get_player(game, player_id))
    }
    %Game{game | update: new_update}
  end
  
  defp emit_update(game) do
    {game.update, %Game{game | update: {%{}, %{}}}}
  end

  defp filter_changed(map1, map2) do
    # different keys error handling?
    Map.filter(map1, fn {k, v} -> v != map2[k] end)
  end
  
  defp word_view(game, player_id) do
    words = Round.get_words(game.round)
    extraword = Words.get_extraword(words, player_id)
    Words.get_words(words, player_id)
    |> Enum.map(fn word -> {word, word == extraword} end)
  end
end
