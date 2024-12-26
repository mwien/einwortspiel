defmodule Einwortspiel.Game.State do
  alias __MODULE__
  alias Einwortspiel.Game.{Info, Player, Round, Settings, View}

  # TODO: replace game by state for function arguments

  defstruct [
    :id,
    :info,
    :players,
    :round,
    :settings,
    :update
  ]

  def init(game_id, options) do
    %State{
      id: game_id,
      info: Info.init(),
      players: %{},
      round: nil,
      settings: Settings.init(options),
      update: %View{general: %{}, players: %{}}
    }
  end

  def add_player(game, player_id, name) do
    if has_player?(game, player_id) do
      {:error, :player_id_exists}
    else
      {:ok,
       %State{game | players: Map.put(game.players, player_id, Player.create(name))}
       |> View.update_new_player(player_id)
       |> View.update_general(game)
       |> emit_update()}
    end
  end

  def start_round(game, _player_id) do
    case can_start_round(game) do
      :ok ->
        new_game = %State{game | round: Round.init(Map.keys(game.players), game.settings)}
        {:ok, {View.get_view(new_game), new_game}}

      {:error, error} ->
        {:error, error}
    end
  end

  def submit_clue(game, player_id, clue) do
    case Round.make_move(game.round, player_id, {:submit_clue, clue}) do
      {:ok, new_round} ->
        {:ok,
         %State{game | round: new_round}
         |> View.update_player(game, player_id)
         |> View.update_general(game)
         |> emit_update()}

      {:error, error} ->
        {:error, error}
    end
  end

  def submit_guess(game, player_id, guess) do
    case Round.make_move(game.round, player_id, {:submit_guess, guess}) do
      {:ok, new_round} ->
        {:ok,
         %State{
           game
           | round: new_round,
             info: Info.evaluate_result(game.info, Round.get_phase(new_round))
         }
         |> View.update_player(game, player_id)
         |> View.update_general(game)
         |> emit_update()}

      {:error, error} ->
        {:error, error}
    end
  end

  # take only active players into account
  def can_start_round(game) do
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

  defp emit_update(game) do
    {game.update, %State{game | update: %View{general: %{}, players: %{}}}}
  end
end
